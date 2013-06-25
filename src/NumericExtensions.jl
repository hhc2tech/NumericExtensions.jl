module NumericExtensions

	import Base.add!, Base.show, Base.getindex, Base.setindex!
	import Base.pointer, Base.size, Base.length, Base.copy, Base.similar
	import Base.map, Base.map!, Base.reduce, Base.mapreduce
	import Base.sum, Base.max, Base.min, Base.dot, Base.LinAlg.BLAS.asum, Base.norm
	import Base.mean, Base.var, Base.std

	export 
		# functors
		to_fparray,

		Functor, UnaryFunctor, BinaryFunctor, TernaryFunctor,
		result_type, evaluate,
		Add, Subtract, Multiply, Divide, Negate, Max, Min,
		Abs, Abs2, Sqrt, Cbrt, Pow, Hypot, FixAbsPow, FMA,
		Floor, Ceil, Round, Trunc,
		Exp, Exp2, Exp10, Expm1, 
		Log, Log2, Log10, Log1p,
		Sin, Cos, Tan, Asin, Acos, Atan, Atan2,
		Sinh, Cosh, Tanh, Asinh, Acosh, Atanh, 
		Erf, Erfc, Gamma, Lgamma, Digamma, 
		Greater, GreaterEqual, Less, LessEqual, Equal, NotEqual,
		Isfinite, Isnan, Isinf,

		xlogx, xlogy, Xlogx, Xlogy,

		# views
		AbstractUnsafeView, UnsafeVectorView, UnsafeMatrixView, UnsafeCubeView,
		ContiguousArray, ContiguousVector, ContiguousMatrix, ContiguousCube,
		unsafe_view,

		# map
		map, map!, map1!, mapdiff, mapdiff!,

		add!, subtract!, multiply!, divide!, negate!, rcp!, 
		sqrt!, abs!, abs2!, pow!, exp!, log!,
		floor!, ceil!, round!, trunc!,

		absdiff, sqrdiff, fma, fma!,

		# vbroadcast
		vbroadcast, vbroadcast!, vbroadcast1!,
		badd, badd!, bsubtract, bsubtract!, bmultiply, bmultiply!, bdivide, bdivide!,

		# reduce
		reduce!, mapreduce!, mapdiff_reduce, mapdiff_reduce!,
		sum!, sum_fdiff, sum_fdiff!,
		max!, max_fdiff, max_fdiff!,
		min!, min_fdiff, min_fdiff!,
		asum, asum!, amax, amax!, amin, amin!, sqsum, sqsum!,  
		dot!, adiffsum, adiffsum!, sqdiffsum, sqdiffsum!,
		adiffmax, adiffmax!, adiffmin, adiffmin!,  
		sum_xlogx, sum_xlogx!, sum_xlogy, sum_xlogy!, 
		vnorm, vnorm!, vdiffnorm, vdiffnorm!,

		# statistics
		mean!, var!, std!, entropy, entropy!,
		logsumexp, logsumexp!, softmax, softmax!,

		# weightsum
		wsum, wsum!, wsum_fdiff, wsum_fdiff!,
		wasum, wasum!, wadiffsum, wadiffsum!,
		wsqsum, wsqsum!, wsqdiffsum, wsqdiffsum!,

		# benchmark
		BenchmarkTable, nrows, ncolumns, add_row!


	include("common.jl")
	include("functors.jl")
	include("unsafe_view.jl")
	
	include("codegen.jl")
	include("map.jl")
	include("vbroadcast.jl")
	include("reduce.jl")
	include("statistics.jl")
	include("weightsum.jl")

	include("benchmark.jl")

end
