#include <stdio.h>
#include "mex.h"


template<class T> int FindMaxComponent(T* input_volume, int num_voxels) {
  int MaxComponent = 0;
  int component;
  for (long k=0;k<num_voxels;k++) {
	component = input_volume[k];
	if (component>MaxComponent)
		MaxComponent = component;
  }
  return MaxComponent;
}

template<class T> void CalcHistogram(float *ComponentHistogram, T* input_volume, int num_voxels) {
  for (long k=0;k<num_voxels;k++) 
		ComponentHistogram[(unsigned int)(input_volume[k])]++;
}

/* Entry Points */
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  int MaxComponent;
  int  dim_array[2];  
  float *ComponentHistogram;

  if (nrhs < 1 || nlhs != 1) {
    mexErrMsgTxt("Usage: [aiHist] = fnLabelsHist(Data, Max Histogram Entry)");
	return;
  } 

if (nrhs == 2 ) 
  MaxComponent = int(*(double *)mxGetData(prhs[1]));
else
{
  if (mxIsUint16(prhs[0])) 
	  MaxComponent = FindMaxComponent((unsigned short *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsUint32(prhs[0]))
	  MaxComponent = FindMaxComponent((int *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsSingle(prhs[0]))
	  MaxComponent = FindMaxComponent((float *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsDouble(prhs[0]))
	  MaxComponent = FindMaxComponent((double *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else {
		mexErrMsgTxt("Use uint16, uint32, float or double only");
		return;
  }}


  dim_array[0] = 1;
  dim_array[1] = MaxComponent+1;
  plhs[0] = mxCreateNumericArray(2, dim_array, mxSINGLE_CLASS, mxREAL);
  ComponentHistogram = (float*)mxGetPr(plhs[0]);
  
  if (mxIsUint16(prhs[0])) 
	  CalcHistogram(ComponentHistogram, (unsigned short *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsUint32(prhs[0]))
	  CalcHistogram(ComponentHistogram, (int *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsSingle(prhs[0]))
	  CalcHistogram(ComponentHistogram, (float *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else if (mxIsDouble(prhs[0]))
	  CalcHistogram(ComponentHistogram, (double *)mxGetData(prhs[0]), mxGetNumberOfElements(prhs[0]));
  else {
		mexErrMsgTxt("Use uint16, uint32, float or double only");
		return;
  }

}

