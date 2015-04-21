/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include <stdio.h>
#include "mex.h"
#define MAX(x,y)(x>y)?(x):(y)
#define MIN(x,y)(x<y)?(x):(y)

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
	double *Timestamp = (double*)mxGetData(prhs[0]);
	double *Values = (double*)mxGetData(prhs[1]);
	double *SampleTS = (double*)mxGetData(prhs[2]);

	const int *dim = mxGetDimensions(prhs[0]);
	int iNumInputs= MAX(dim[0],dim[1]);

	const int *dim1 = mxGetDimensions(prhs[2]);
	int iNumSamples = MAX(dim1[0],dim1[1]);
	int m = MIN(dim1[0],dim1[1]);

	plhs[0] = mxCreateNumericArray(2, dim1, mxDOUBLE_CLASS, mxREAL);
	double *Out = (double*)mxGetPr(plhs[0]);


	mwSize     NStructElems;
	for (int k=0;k<=2;k++) {
		NStructElems = mxGetNumberOfElements(prhs[k]);
		if (NStructElems == 0)
			return;
	}
	

	double fPrevValue;
	int iCurrInput = 0;
	double fCurrTS;

	if (SampleTS[0] < Timestamp[0]){
		fPrevValue = Values[0]; // or NaN
        fCurrTS = Timestamp[0];
	} else {
		// find previous value
		while(iCurrInput < iNumInputs && SampleTS[0] > Timestamp[iCurrInput])
			iCurrInput++;
		// now Timestamp[iCurrInput] > SampleTS[0]
		fPrevValue = Values[iCurrInput-1];
		fCurrTS = Timestamp[iCurrInput];
	}

	for (int k=0; k<iNumSamples;k++) {
		if (SampleTS[k] >= fCurrTS) {
			while (iCurrInput < iNumInputs && SampleTS[k] >= fCurrTS) {
				iCurrInput++;
				fCurrTS = Timestamp[iCurrInput];
			}
			fPrevValue = Values[iCurrInput-1];
		}

		Out[k] = fPrevValue;
	}

}
