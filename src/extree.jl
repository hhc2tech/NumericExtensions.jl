# Expression tree and manipulation

#################################################
#
#  Expression types
#
#################################################

abstract AbstractExpr
abstract EwiseExpr <: AbstractExpr

is_scalar_expr(ex::AbstractExpr) = false

##### Generic expressions

# Generic expressions are not further parsed. 
# Instead, they are processed in such way, new variables
# will be created to capture their values.

immutable EGenericExpr <: AbstractExpr
	expr::Expr
end


##### Simple expressions

### Notes
#
#  Some expression tree types (e.g. ERef) requires
#  simple expressions as its arguments. 
#
#  The construction of these expressions will 
#  separate complex expressions and assign them
#  to a new variable.
#
### 
abstract SimpleExpr <: EwiseExpr

typealias NumOrSym Union(Number,Symbol)

immutable EConst{T<:Number} <: SimpleExpr
	value::T
end

EConst{T<:Number}(x::T) = EConst{T}(x)
is_scalar_expr(ex::EConst) = true

immutable EVar <: SimpleExpr
	sym::Symbol
	isscalar::Bool  # inferred as scalar at parsing time

	EVar(s::Symbol) = new(s, false)
	EVar(s::Symbol, tf::Bool) = new(s, tf)	
end
is_scalar_expr(ex::EVar) = ex.isscalar


immutable EEnd end
typealias ERangeArg Union(EConst,EVar,EEnd)

immutable ERange{Args<:(ERangeArg...,)} <: SimpleExpr
	args::Args
end
ERange{Args<:(SimpleExpr...,)}(args::Args) = ERange{Args}(args)

##### Function calls

immutable EFun
	sym::Symbol
end

is_unary_ewise(f::EFun) = (f.sym in UNARY_EWISE_FUNCTIONS)
is_binary_ewise(f::EFun) = (f.sym in BINARY_EWISE_FUNCTIONS)
is_binary_sewise(f::EFun) = (f.sym in BINARY_SEWISE_FUNCTIONS)

is_unary_reduc(f::EFun) = (f.sym in UNARY_REDUC_FUNCTIONS)
is_binary_reduc(f::EFun) = (f.sym in BINARY_REDUC_FUNCTIONS)

type EMapCall{Args<:(AbstractExpr...,)} <: EwiseExpr
	fun::EFun
	args::Args
	isscalar::Bool
end

EMapCall{Args<:(AbstractExpr...,)}(f::EFun, args::Args; isscalar=false) = EMapCall{Args}(f, args, isscalar)
is_scalar_expr(ex::EMapCall) = ex.isscalar

type EReducCall{Args<:(AbstractExpr...,)} <: AbstractExpr
	fun::EFun
	args::Vector{AbstractExpr}
end

EReducCall{Args<:(AbstractExpr...,)}(f::EFun, args::Args) = EReducCall{Args}(f, args)
is_scalar_expr(ex::EReducCall) = true

type EGenericCall{Args<:(AbstractExpr...,)} <: AbstractExpr
	fun::EFun
	args::Vector{AbstractExpr}
	isscalar::Bool
end

EGenericCall{Args<:(AbstractExpr...,)}(f::EFun, args::Args; isscalar=false) = EGenericCall{Args}(f, args, isscalar)
is_scalar_expr(ex::EGenericCall) = ex.isscalar

# Note: other kind of function call expressions should 
# be captured by EGenericExpr

typealias ECall Union(EMapCall, EReducCall, EGenericCall)
numargs(ex::ECall) = length(ex.args)


##### References

immutable EColon end

typealias ERefArg Union(SimpleExpr, EColon)

type ERef{Args<:(ERefArg...,)} <: EwiseExpr
	arr::EVar    # the host array
	args::Args
end

ERef{Args<:(ERefArg...,)}(h::EVar, args::Args) = ERef{Args}(h, args)

##### Assignment expression

type EAssignment{Lhs<:Union(EVar,ERef),Rhs<:AbstractExpr} <: AbstractExpr
	lhs::Lhs
	rhs::Rhs
end

EAssignment{Lhs<:Union(EVar,ERef),Rhs<:AbstractExpr}(l::Lhs, r::Rhs) = EAssignment{Lhs,Rhs}(l,r)

##### Block Expression

type EBlock <: AbstractExpr
	exprs::Vector{AbstractExpr}

	BlockExpr() = new(Array(AbstractExpr, 0))
	BlockExpr(a::Vector{AbstractExpr}) = new(a)
end


#################################################
#
#  Expression tree construction
#
#################################################

typealias ExprContext Vector{EAssignment}
expr_context() = EAssignment[]
make_blockexpr(ctx::ExprContext, ex::AbstractExpr) = Expr(:block, ctx..., ex)

function lift_expr!(ctx::ExprContext, ex::AbstractExpr)
	tmpvar = EVar(gensym("_tmp"))
	push!(ctx, EAssignment(tmpvar, ex))
	return tmpvar
end

scalar(x::Number) = x
scalar(x) = error("Input argument is not a scalar.")

extree(ex::AbstractExpr) = ex
extree(x::Number) = EConst(x)
extree(s::Symbol) = EVar(s)

function extree(x::Expr) 
	ctx = expr_context()
	ex = extree!(ctx, x)
	isempty(ctx) ? ex : make_blockexpr(ctx, ex)
end

extree!(ctx::ExprContext, x::Number) = extree(x)
extree!(ctx::ExprContext, x::Symbol) = extree(x)

function extree!(ctx::ExprContext, x::Expr)
	h::Symbol = x.head
	h == :(:)    ? extree_for_range!(ctx, x) :
	h == :(ref)  ? extree_for_ref!(ctx, x) :
	h == :(call) ? extree_for_call!(ctx, x) :
	EGenericExpr(x)
end


###
#
# Notes:
# - In such cases as f(x) where x is a constant, 
#   then when f is some known function, f(x)
#   will be evaluated upon construction.
#   However, if f is one of those recognizable
#   function, then we cannot assume f(x) as
#   a constant scalar, as f(x) can be of arbitary
#   type when f is unknown.
#
#   The same applies to binary & ternary functions.
#

# is_s2s_map returns true when f yields a scalar when
# applied to n scalar arguments.

function is_s2s_func(f::EFun, n::Int)
	n == 1 ? (is_unary_ewise(f) || is_unary_reduc(f)) :
	n == 2 ? (return is_binary_ewise(f) || is_binary_reduc(f)) : false
end

const end_sym = symbol("end")

function erangearg!(ctx::ExprContext, a)
	if isa(a, Number)
		return EConst(a)
	elseif isa(a, Symbol)
		return (a == end_sym || a == :(:)) ? EEnd() : EVar(a)
	else
		_a = extree!(ctx, a)
		return isa(_a, ERangeArg) ? _a : lift_expr!(ctx, _a)
	end
end

function extree_for_range!(ctx::ExprContext, x::Expr)
	nargs = length(x.args)
	2 <= nargs <= 3 || error("extree: a range must have two or three arguments.")
	ERange(tuple([erangearg!(ctx, a) for a in x.args]...))
end

function erefarg!(ctx::ExprContext, a)
	if isa(a, Number)
		return EConst(a)
	elseif isa(a, Symbol)
		return a == :(:) ? EColon() : EVar(a)
	else
		_a = extree!(ctx, a)
		return isa(_a, ERefArg) ? _a : lift_expr!(ctx, _a)
	end
end

function extree_for_ref!(ctx::ExprContext, x::Expr)
	nargs = length(x.args)
	nargs >= 1 || error("extree: a ref expression must have at least one argument.")
	ERef(tuple([erefarg!(ctx, a) for a in x.args]...))
end

function extree_for_call!(ctx::ExprContext, x::Expr)
	fsym = x.args[1]
	isa(fsym, Symbol) || error("extree: the function name must be a symbol.")
	f = EFun(fsym)
	nargs = length(x.args) - 1

	if nargs > 0
		_args = [extree_for_arg!(ctx, a) for a in x.args[2:end]]
		is_s2s = is_s2s_func(f, nargs)

		if is_s2s && all([isa(a, EConst) for a in _args]) # constant propagation			
			return EConst(eval_const(f, _args))

		else 
			rs = is_s2s && all([is_scalar_expr(a) for a in _args])
			argtup = tuple(_args...)

			if is_reduc_call(f, argtup)
				return EReducCall(f, argtup; isscalar=rs)
			elseif is_ewise_call(f, argtup)
				return EMapCall(f, argtup; isscalar=rs)
			else
				return EGenericCall(f, argtup; isscalar=rs)
			end
		end
	else
		return EGenericCall(f, ())
	end
end


## should_be_lifted(a) returns whether a should be lifted to the context 
## when a is an argument of an host expression.

should_be_lifted(ex::AbstractExpr) = true
should_be_lifted(ex::EwiseExpr) = !is_scalar_expr(ex)
should_be_lifted(ex::EConst) = false
should_be_lifted(ex::EVar) = false

function extree_for_arg!(ctx::ExprContext, x::Expr)
	ex = extree!(ctx, x)
	should_be_lifted(ex) ? lift_expr!(ctx, ex) : ex
end
