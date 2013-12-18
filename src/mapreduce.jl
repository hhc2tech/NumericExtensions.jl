# map-reduction

#################################################
#
#   facilities for code generation
#
################################################

function generate_argparamlist(nargs::Int; use_contiguous=false)
	if nargs == 1
		[:(a1::NumericArray)]
	else
		[Expr(:(::), symbol("a$i"), :ArrOrNum) for i = 1 : nargs]
	end
end

generate_arglist(nargs::Int) = [symbol("a$i") for i = 1 : nargs]

function functor_evalexpr(f::Symbol, args::Vector{Symbol}, i::Symbol; usediff::Bool=false) 
	if usediff
		@assert length(args) == 2
		a1, a2 = args[1], args[2]
		Expr(:call, :evaluate, f, :(getvalue($a1, $i) - getvalue($a2, $i)) )
	else
		if length(args) == 1
			a = args[1]
			Expr(:call, :evaluate, f, :($a[$i]))
		else
			es = [Expr(:call, :getvalue, a, i) for a in args]
			Expr(:call, :evaluate, f, es...)
		end
	end
end

function prepare_arguments(N::Int)
	if N > 0
		aparams = generate_argparamlist(N)
		args = generate_arglist(N)
		(aparams, args, false)
	else
		@assert N == -2
		aparams = generate_argparamlist(2)
		args = generate_arglist(2)
		(aparams, args, true)
	end	
end


#################################################
#
#   macros to generate functions
#
#################################################

macro code_mapreducfuns(N)
	# argument preparation

	(aparams, args, udiff) = prepare_arguments(N)
	ti  = functor_evalexpr(:f, args, :i;  usediff=udiff)
	ti1 = functor_evalexpr(:f, args, :i1; usediff=udiff)
	ti2 = functor_evalexpr(:f, args, :i2; usediff=udiff)

	fn = N > 0 ? N : 1

	# function names

	_sumf = :_sum
	 sumf = :sum
	_maxf = :_maximum
	 maxf = :maximum
	_minf = :_minimum
	 minf = :minimum

	meanf  = :mean
	nnmaxf = :nonneg_maximum
	nnminf = :nonneg_minimum

	if udiff
		_sumf = :_sumfdiff
		 sumf = :sumfdiff
		_maxf = :_maxfdiff
		 maxf = :maxfdiff
		_minf = :_minfdiff
		 minf = :minfdiff

		meanf  = :meanfdiff
		nnmaxf = :nonneg_maxfdiff
		nnminf = :nonneg_minfdiff
	end

	# code skeletons

	quote
		# sum & mean

		global $_sumf
		function ($_sumf)(ifirst::Int, ilast::Int, f::Functor{$fn}, $(aparams...))
			i1 = ifirst
			i2 = ifirst + 1

			s1 = $(ti1)
			if ilast > ifirst
				@inbounds s2 = $(ti2)

				i1 += 2
				i2 += 2
				while i1 < ilast
					@inbounds s1 += $(ti1)
					@inbounds s2 += $(ti2)
					i1 += 2
					i2 += 2
				end

				if i1 == ilast
					@inbounds s1 += $(ti1)
				end

				return s1 + s2
			else
				return s1
			end			
		end

		global $sumf
		function ($sumf)(f::Functor{$fn}, $(aparams...))
			n = maplength($(args...))
			n == 0 ? 0.0 : ($_sumf)(1, n, f, $(args...))
		end

		global $meanf
		function ($meanf)(f::Functor{$fn}, $(aparams...))
			n = maplength($(args...))
			n == 0 ? NaN : ($_sumf)(1, n, f, $(args...)) / n
		end

		# maximum & minimum

		global $_maxf
		function ($_maxf)(ifirst::Int, ilast::Int, f::Functor{$fn}, $(aparams...))
			i = ifirst
			s = $(ti)

			while i < ilast
				i += 1
				@inbounds vi = $(ti)
				if vi > s || (s != s)
					s = vi
				end
			end
			return s
		end

		global $maxf
		function ($maxf)(f::Functor{$fn}, $(aparams...))
			n = maplength($(args...))
			n > 0 || error("Empty arguments not allowed.")
			($_maxf)(1, n, f, $(args...))
		end

		global $nnmaxf
		function ($nnmaxf)(f::Functor{$fn}, $(aparams...))
			n = maplength($(args...))
			n == 0 ? 0.0 : ($_maxf)(1, n, f, $(args...))
		end

		global $_minf
		function ($_minf)(ifirst::Int, ilast::Int, f::Functor{$fn}, $(aparams...))
			i = ifirst
			s = $(ti)

			while i < ilast
				i += 1
				@inbounds vi = $(ti)
				if vi < s || (s != s)
					s = vi
				end
			end
			return s
		end

		global $minf
		function ($minf)(f::Functor{$fn}, $(aparams...))
			n = maplength($(args...))
			n > 0 || error("Empty arguments not allowed.")
			($_minf)(1, n, f, $(args...))
		end

		global $nnminf
		function ($nnminf)(f::Functor{$fn}, $(aparams...))
			n = maplength($(args...))
			n == 0 ? 0.0 : ($_minf)(1, n, f, $(args...))
		end
	end
end


#################################################
#
#   generate specific functions
#
#################################################

@code_mapreducfuns 1
@code_mapreducfuns 2
@code_mapreducfuns 3
@code_mapreducfuns (-2)  # for *fdiff


#################################################
#
#   derived functions
#
#################################################

sumabs(a::NumericArray) = sum(AbsFun(), a)
maxabs(a::NumericArray) = maximum(AbsFun(), a)
minabs(a::NumericArray) = minimum(AbsFun(), a)
meanabs(a::NumericArray) = mean(AbsFun(), a)

sumsq(a::NumericArray) = sum(Abs2Fun(), a)
meansq(a::NumericArray) = mean(Abs2Fun(), a)

dot(a::NumericVector, b::NumericVector) = sum(Multiply(), a, b)
dot(a::NumericArray, b::NumericArray) = sum(Multiply(), a, b)

sumabsdiff(a::ArrOrNum, b::ArrOrNum) = sumfdiff(AbsFun(), a, b)
maxabsdiff(a::ArrOrNum, b::ArrOrNum) = maxfdiff(AbsFun(), a, b)
minabsdiff(a::ArrOrNum, b::ArrOrNum) = minfdiff(AbsFun(), a, b)
meanabsdiff(a::ArrOrNum, b::ArrOrNum) = meanfdiff(AbsFun(), a, b)

sumsqdiff(a::ArrOrNum, b::ArrOrNum) = sumfdiff(Abs2Fun(), a, b)
maxsqdiff(a::ArrOrNum, b::ArrOrNum) = maxfdiff(Abs2Fun(), a, b)
minsqdiff(a::ArrOrNum, b::ArrOrNum) = minfdiff(Abs2Fun(), a, b)
meansqdiff(a::ArrOrNum, b::ArrOrNum) = meanfdiff(Abs2Fun(), a, b)

sumxlogx(a::NumericArray) = sum(XlogxFun(), a)
sumxlogy(a::ArrOrNum, b::ArrOrNum) = sum(XlogyFun(), a, b)
entropy(a::NumericArray) = -sumxlogx(a)


