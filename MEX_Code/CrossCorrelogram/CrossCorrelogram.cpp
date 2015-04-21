#include <stdio.h>
#include <math.h>
#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {
    if (nrhs != 4)
	   return;

	double *afSpikesA = (double*)mxGetData(prhs[0]);
	double *afSpikesB = (double*)mxGetData(prhs[1]);
	double WinSizeMS = *(double*)mxGetData(prhs[2]);
	double BinSizeMS = *(double*)mxGetData(prhs[3]);

	double WinSizeSec = WinSizeMS / 1e3;
	double BinSizeSec = BinSizeMS / 1e3;

	int nA = (int) mxGetNumberOfElements(prhs[0]);
	int nB = (int) mxGetNumberOfElements(prhs[1]);

	int iStartB = 0;
	// How many bins
	int NumBins = (int) ceil(2*WinSizeSec/BinSizeSec);
	if (NumBins % 2 != 0)
		NumBins++;
	// Make sure bin number is always even


	mwSize dim[2] = {1, NumBins};
	plhs[0] = mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
	
	double *Correlogram = (double*)mxGetPr(plhs[0]);
	double *BinCenterTime = (double*)mxGetPr(plhs[1]);


	for (int k=0;k<NumBins;k++) {
		Correlogram[k] = 0;
		BinCenterTime[k] = (BinSizeSec/2 + BinSizeSec*(k-NumBins/2)) * 1e3;
	}

	int NumBinsWithNegativeTime = NumBins/2;

	for (int SpikeIterA=0; SpikeIterA < nA; SpikeIterA++) {
		double RefTime = afSpikesA[SpikeIterA];
		for (int SpikeIterB = iStartB;SpikeIterB < nB; SpikeIterB++) {

			double TimeInWindowSec = afSpikesB[SpikeIterB] - RefTime;
			if (TimeInWindowSec < -WinSizeSec) {
				iStartB = SpikeIterB;
				continue;
			}
			if (TimeInWindowSec >= WinSizeSec)
				break;

			// TimeInWindow is inside window!
			// round to nearest integer
			double x = TimeInWindowSec / BinSizeSec;
			double rm = x-floor(x);
			double y;
			if (rm < 0) {
				if (rm >= 0.5)
					y = floor(x);
				else
					y = ceil(x);
			}
			else
			{
				if (rm >=0.5)
					y = ceil(x);
				else
					y= floor(x);
			}
			// convert to indices
			int Index = NumBinsWithNegativeTime + (int) y;
			if (!(Index >= 0 && Index < NumBins)) 
				int dbg = 1;
			else
				Correlogram[Index]++;
		}
	}

}