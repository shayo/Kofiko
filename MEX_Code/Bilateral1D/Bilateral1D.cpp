/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include <stdio.h>
#include "mex.h"
#include "math.h"
#define MAX(x,y)(x>y)?(x):(y)
#define MIN(x,y)(x<y)?(x):(y)
#define SQR(x)((x)*(x))

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
  if (nrhs < 4 || nlhs != 1) {
    mexErrMsgTxt("Usage: afFilteredSignal = fnBiLateral1D(afOriginalSignal,fWidth,fBlurSigma,fEdgeSigma)");
	return;
  } 

	double *afOriginalSignal = (double*)mxGetData(prhs[0]);
	int  fWidth= (int) *(double*)mxGetData(prhs[1]);
	double fBlurSigma= *(double*)mxGetData(prhs[2]);
	double fEdgeSigma= *(double*)mxGetData(prhs[3]);

	int iSignalLength = mxGetNumberOfElements(prhs[0]);

	// Pre-compute Gaussian distance weights.
	double *afGaussian = new double[2*fWidth+1];
	double deno = (2*SQR(fBlurSigma));
	for (int j=0;j<2*fWidth+1;j++) {
		double x = j-fWidth;
		afGaussian[j] = exp(-(x*x)/deno);
	}
	const int* dim = mxGetDimensions(prhs[0]);
	plhs[0] = mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
	double *Out = (double*)mxGetPr(plhs[0]);

	for (int k=0;k<iSignalLength;k++) {

         int iMin = MAX(k-fWidth,0);
         int iMax = MIN(k+fWidth,iSignalLength-1);

		 double S=0;
		 double Sd = 0;
		 for (int i=iMin;i<=iMax;i++) {
			double fValue = afOriginalSignal[i];
		    double Hi = exp(-SQR(fValue-afOriginalSignal[k])/(2*SQR(fEdgeSigma)));
			double Di = Hi * afGaussian[i-k+fWidth];
			Sd+= Di;
			S+=Di * afOriginalSignal[i];
		 }
		 Out[k] = S / Sd;
	}
}
