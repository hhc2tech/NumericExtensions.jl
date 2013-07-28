module NumericExtensions

	# import functions to be extended

	import Base.add!, Base.show, Base.getindex, Base.setindex!
	import Base.pointer, Base.size, Base.length, Base.copy, Base.similar
	import Base.map, Base.map!, Base.reduce, Base.mapreduce
	import Base.diagm
	import Base.+, Base.*, Base.\, Base./
	import Base.sum, Base.max, Base.min, Base.dot, Base.LinAlg.BLAS.asum, Base.norm
	import Base.mean, Base.var, Base.varm, Base.std, Base.stdm
	import Base.logdet, Base.full, Base.inv, Base.diag

	# import of useful BLAS & LAPACK routines
	
    import Base.LinAlg.BLAS.axpy!, Base.LinAlg.BLAS.nrm2
    import Base.LinAlg.BLAS.gemv!, Base.LinAlg.BLAS.gemv
    import Base.LinAlg.BLAS.gemm!, Base.LinAlg.BLAS.gemm    
    import Base.LinAlg.BLAS.trmv!, Base.LinAlg.BLAS.trmv
    import Base.LinAlg.BLAS.trmm!, Base.LinAlg.BLAS.trmm
    import Base.LinAlg.LAPACK.trtrs! 

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

		Recip,
		logit, logistic, xlogx, xlogy, Logit, Logistic, Xlogx, Xlogy,

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

		# diagop
		add_diag!, add_diag, set_diag!, set_diag,

		# reduce
		reduce!, mapreduce!, mapdiff_reduce, mapdiff_reduce!,
		sum!, sum_fdiff, sum_fdiff!,
		max!, max_fdiff, max_fdiff!,
		min!, min_fdiff, min_fdiff!,
		asum, asum!, amax, amax!, amin, amin!, sqsum, sqsum!,  
		dot!, adiffsum, adiffsum!, sqdiffsum, sqdiffsum!,
		adiffmax, adiffmax!, adiffmin, adiffmin!,  
		sum_xlogx, sum_xlogx!, sum_xlogy, sum_xlogy!, 

		# norms
		vnorm, vnorm!, vdiffnorm, vdiffnorm!, normalize, normalize!,

		# statistics
		mean!, var!, varm!, std!, stdm!, entropy, entropy!,
		logsumexp, logsumexp!, softmax, softmax!,

		# weightsum
		wsum, wsum!, wsum_fdiff, wsum_fdiff!,
		wasum, wasum!, wadiffsum, wadiffsum!,
		wsqsum, wsqsum!, wsqdiffsum, wsqdiffsum!,

		# pdmat
        AbstractPDMat, PDMat, PDiagMat, ScalMat, 
        dim, full, whiten, whiten!, unwhiten, unwhiten!, add_scal!, add_scal,
        quad, quad!, invquad, invquad!, X_A_Xt, Xt_A_X, X_invA_Xt, Xt_invA_X,

		# benchmark
		BenchmarkTable, nrows, ncolumns, add_row!


	# codes

	include("common.jl")
	include("functors.jl")
	include("unsafe_view.jl")
	
	include("codegen.jl")
	include("map.jl")
	include("vbroadcast.jl")
	include("diagop.jl")
	include("reduce.jl")
	include("norms.jl")
	include("statistics.jl")
	include("weightsum.jl")

	include("pdmat.jl")

	include("benchmark.jl")
end
