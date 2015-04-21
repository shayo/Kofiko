/*
% Copyright (c) 2011 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include <stdio.h>
#include "mex.h"
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	// Syntax:
	// [a2fAvg] = fnAverageByCell(a2bRaster, aiStimulusIndex,  acConditionInd)

	
	double *Raster = (double*)mxGetData(prhs[0]);

	const int *input_dim_array = mxGetDimensions(prhs[0]);
	int NumTrials = input_dim_array[0];
	int NumTimePoints = input_dim_array[1];	

	double *Stimuli = (double*)mxGetData(prhs[1]);
	int iNumStimuli = mxGetNumberOfElements(prhs[1]);
		
	int iNumConditions = mxGetNumberOfElements(prhs[2]);

	double NaN = mxGetNaN();

	int output_dim_array[2];
	output_dim_array[0] = iNumConditions;
	output_dim_array[1] = NumTimePoints;
	plhs[0] = mxCreateNumericArray(2, output_dim_array, mxDOUBLE_CLASS, mxREAL);
	double *PSTH = (double*) mxGetPr(plhs[0]);

	for (int k=0;k<iNumConditions*NumTimePoints;k++)
		PSTH[k] = NaN;

	double *TMP_PSTH = new double[NumTimePoints];

	for (int iConditionIter=0;iConditionIter<iNumConditions;iConditionIter++) {
		mxArray *M = mxGetCell(prhs[2],iConditionIter);
		int iNumStimuliInCondition = mxGetNumberOfElements(M);
		double *ConditionInd = (double*)mxGetPr(M);
		
		for (int t=0;t<NumTimePoints;t++)
			TMP_PSTH[t] = 0;
		
		int iNumMatches = 0;
		for (int iStimuliIter=0;iStimuliIter<iNumStimuli;iStimuliIter++) {
			for (int i=0;i<iNumStimuliInCondition;i++) {

				if (Stimuli[iStimuliIter] == ConditionInd[i]) {
					// Add to PSTH
					for (int t=0;t<NumTimePoints;t++) {
						TMP_PSTH[t] += Raster[t * iNumStimuli + iStimuliIter ];
					}
					iNumMatches++;
				}

			}
		}

		for (int t=0;t<NumTimePoints;t++) {
			PSTH[t* iNumConditions + iConditionIter] = TMP_PSTH[t] / iNumMatches;
		}
	}


	delete [] TMP_PSTH;
}


/*
iNumConditions = length(acConditionInd);
iRaster_Length = size(a2bRaster,2);

a2fAvg = NaN*ones(iNumConditions, iRaster_Length);

for iConditionIter=1:iNumConditions
    aiRelevantRasterInd = find(ismember(aiStimulusIndex, acConditionInd{iConditionIter}));
    if ~isempty(aiRelevantRasterInd)
        a2fAvg(iConditionIter,:) = mean(a2bRaster(aiRelevantRasterInd,:),1);
    end
end
*/