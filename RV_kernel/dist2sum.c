#include "mex.h"
#include "matrix.h"
#include "math.h"
#define SQR(x) (x)*(x)


double innerprod(double *v1, double *v2, int nx, int ny, int dim) 
{
    int i, j, k;
    double dtmp;
    
    dtmp = 0;
    for(i=0; i<nx; i++) 
    {
        for(j=0; j<ny; j++) 
        {
            for (k = 0; k < dim; k++) 
            {
                dtmp = dtmp + SQR(v1[k*nx+i] - v2[k*ny+j]);
            }
        }
    }
    return(dtmp);
}

/*  In the function, the trainX is the [dim, num_train] = size(trainX), this will faciliate the following
 *  calculation
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    double *X, *Y, *dist2sum;
	int nx, ny, dim;
    
	/* Input variable*/
    X = mxGetPr(prhs[0]);        /* randperm position of the array */
    Y = mxGetPr(prhs[1]);        /* randperm position of the array */
   
    nx = mxGetM(prhs[0]);
    ny = mxGetM(prhs[1]);
    dim = mxGetN(prhs[0]);

    /* Output Variable*/    
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	dist2sum = mxGetPr(plhs[0]);
    
    dist2sum[0] = innerprod(X, Y,nx,ny,dim);
}


