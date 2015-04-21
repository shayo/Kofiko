/*
% Copyright (c) 2012 Shay Ohayon, California Institute of Technology.
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
	double *SortedTS = (double*)mxGetData(prhs[0]);
	double *Channels = (double*)mxGetData(prhs[1]);
	double *Waves = (double*)mxGetData(prhs[2]);
	double *TetrodeTable= (double*)mxGetData(prhs[3]);

	const int *dimwaves = mxGetDimensions(prhs[2]);
	int iNumWavePts= dimwaves[1];
	int iNumInWaves= dimwaves[0];

	const int *dim = mxGetDimensions(prhs[3]);
	int iNumTetrodes = dim[0];

	int iNumTS = mxGetNumberOfElements(prhs[0]);

	int iNumUniqueTS = 0;
	for (int k=0;k<iNumTS-1;k++) 
		iNumUniqueTS+= (SortedTS[k] == SortedTS[k+1]);
	
	int iActiveEntry = 1;
	int iActiveLine = 0;
	double fPrevTS = SortedTS[0];
	int *a2iInd = new int[4 *iNumTetrodes]; //4 x iNumTetrodes
	for (int k=0;k<4*iNumTetrodes;k++) 
		a2iInd[k] = 0;

	double *a2fSortedEventsTable = new double [iNumTetrodes*iNumUniqueTS * 5]; //, 5);  % indices to wave forms/ts. last column denotes which tetrode was triggered



	for (int iIter=0;iIter < iNumTS;iIter++) {

		double fCurrentTS = SortedTS[iIter];
		int iCurrentChannel = (int)Channels[iIter];
	
		int iTetrodeNumber=0, iChannelInTetrode;
		int  iIndex = -1;
		for (iTetrodeNumber=0;iTetrodeNumber<iNumTetrodes;iTetrodeNumber++) {
			for (iChannelInTetrode=0;iChannelInTetrode<4;iChannelInTetrode++) {
				if (iCurrentChannel == TetrodeTable[iTetrodeNumber + iChannelInTetrode*iNumTetrodes]) {
				iIndex = iNumTetrodes*iChannelInTetrode + iTetrodeNumber;
				break;
				}
			}
			if (iIndex > 0)
				break;
		}
		

		if (fCurrentTS == fPrevTS) {
			if (iIndex >= 0 && iIndex < iNumTetrodes*4)
				a2iInd[iIndex] = iIter+1;

		} else {
			// add events to the table...
			
			// find valid entries in a2iInd (i.e., those with full information).
			for (int iTetrodeIter=0;iTetrodeIter<iNumTetrodes;iTetrodeIter++) {
				bool bAllEventsPresent = a2iInd[iNumTetrodes*0 + iTetrodeIter] > 0 &&
										 a2iInd[iNumTetrodes*1 + iTetrodeIter] > 0 &&
										 a2iInd[iNumTetrodes*2 + iTetrodeIter] > 0 &&
										 a2iInd[iNumTetrodes*3 + iTetrodeIter] > 0;

				if (bAllEventsPresent) {
					// Add this event.
					a2fSortedEventsTable[iActiveLine*5+0] = a2iInd[iNumTetrodes*0 + iTetrodeIter];
					a2fSortedEventsTable[iActiveLine*5+1] = a2iInd[iNumTetrodes*1 + iTetrodeIter];
					a2fSortedEventsTable[iActiveLine*5+2] = a2iInd[iNumTetrodes*2 + iTetrodeIter];
					a2fSortedEventsTable[iActiveLine*5+3] = a2iInd[iNumTetrodes*3 + iTetrodeIter];
					a2fSortedEventsTable[iActiveLine*5+4] = iTetrodeIter+1;
					iActiveLine++;
				}

			}

			for (int k=0;k<4*iNumTetrodes;k++) 
				a2iInd[k] = 0;
			
			fPrevTS = fCurrentTS ;	
			if (iIndex >= 0 && iIndex < iNumTetrodes*4)
				a2iInd[iIndex] = iIter+1;
		}


	}

	int dim_out[2] ={5,iActiveLine};
	plhs[0] = mxCreateNumericArray(2, dim_out, mxDOUBLE_CLASS, mxREAL);
	double *Out = (double*)mxGetPr(plhs[0]);

	int dim_wave_out[2] ={iActiveLine,4*iNumWavePts};
	plhs[1] = mxCreateNumericArray(2, dim_wave_out, mxDOUBLE_CLASS, mxREAL);
	double *WaveOut = (double*)mxGetPr(plhs[1]);

	for (int i=0;i<iActiveLine;i++) {

		for (int j=0;j<5;j++) {
			Out[i*5+j]=a2fSortedEventsTable[i*5+j];
		}

		// build the groupped wave data
		for (int j=0;j<4;j++) {
			int index = a2fSortedEventsTable[i*5+j]-1;
			for (int w=0;w<iNumWavePts;w++) {
				WaveOut[iActiveLine*(w+j*iNumWavePts)+i] = Waves[w*iNumInWaves+index];
			}
		}

	}

	delete [] a2iInd;
	delete [] a2fSortedEventsTable;


}
