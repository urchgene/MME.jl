##########################################################################################
###### This solves sT MME using univariate systems of equations 
###### Developer: Uche Godfrey Okeke
###### This is for equal design matrices (X,Z) problem ie same traits, same indvs...
##########################################################################################


using LinearAlgebra
using PositiveFactorizations, DataFrames
using SparseArrays, IterativeSolvers

function solvePCG_st(X, Z, Vg, Ve, Y, Ainv, linenames)

	#### Calculate lambda
	D = Ve/Vg

	#### Solve systems of equations via univariate systems
	
	Sigma = D*Ainv;
	XtX = X'*X; XtZ = X'*Z; ZtX = Z'*X; ZtZG = Z'*Z + Sigma;
	C = hcat(vcat(XtX, ZtX), vcat(XtZ, ZtZG)); C = sparse(C);
	RHS = vcat(X'*Y, Z'*Y)

        ## Clean memory first...
        XtX = 0; XtZ = 0; ZtX = 0; ZtZG = 0; Rinvs = 0; Sigma = 0; GC.gc()

	#### Solve by PCG iteration on bicgstabl... 
	GC.gc()
	theta = bicgstabl(C, RHS, 2, Pl = Diagonal(C), max_mv_products = 2000);
	beta = theta[1:size(X,2)];
        uhat = theta[length(beta)+1: end];        
	uhat = DataFrame(Lines=linenames, Uhat=uhat);

	m11 =  Dict(
                :uhat => uhat,
                :beta => beta)

	return(m11)

end