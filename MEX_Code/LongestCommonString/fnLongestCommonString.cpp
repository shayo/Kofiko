/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include <stdio.h>
#include "mex.h"
#include "matrix.h"
#define MAX(x,y)(x>y)?(x):(y)


#include <string>
 
using std::string;
 

template<class T> int LongestCommonSubstring(T* str1, T* str2, int n1, int n2, int &IndexI, int &IndexJ)
{
     if(n1 == 0 || n2 == 0)
     {
          return 0;
     }
 
     int *curr = new int [n2];
     int *prev = new int [n2];
     int *swap = NULL;
     int maxSubstr = 0;
     for(int i = 0; i<n1; ++i)
     {
          for(int j = 0; j<n2; ++j)
          {
               if(str1[i] != str2[j])
               {
                    curr[j] = 0;
               }
               else
               {
                    if(i == 0 || j == 0)
                    {
                         curr[j] = 1;						 
                    }
                    else
                    {
                         curr[j] = 1 + prev[j-1];
                    }
                    //The next if can be replaced with:
                    //maxSubstr = max(maxSubstr, curr[j]);
                    //(You need algorithm.h library for using max())
                    if(maxSubstr < curr[j])
                    {
                         maxSubstr = curr[j];
						 IndexJ= j;
						 IndexI= i;
                    }
               }
          }
          swap=curr;
          curr=prev;
          prev=swap;
     }
     delete [] curr;
     delete [] prev;

	 IndexI -= maxSubstr-2;
	 IndexJ -= maxSubstr-2;

     return maxSubstr;
}





void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	int buflen1 =mxGetNumberOfElements(prhs[0]);
	int buflen2 = mxGetNumberOfElements(prhs[1]);

	int LCS = -1;
	int IndexI,IndexJ;

	if (mxIsSingle(prhs[0])) {
		float *buf1= (float*)mxGetData(prhs[0]);
		float *buf2= (float*)mxGetData(prhs[1]);
		
		LCS = LongestCommonSubstring(buf1,buf2,buflen1,buflen2,IndexI,IndexJ);
	} else if (mxIsDouble(prhs[0])) {
		double *buf1= (double*)mxGetData(prhs[0]);
		double *buf2= (double*)mxGetData(prhs[1]);
		
		LCS = LongestCommonSubstring(buf1,buf2,buflen1,buflen2,IndexI,IndexJ);
	} else if (mxIsUint16(prhs[0]) || mxIsInt16(prhs[0])) {
		short *buf1= (short*)mxGetData(prhs[0]);
		short *buf2= (short*)mxGetData(prhs[1]);
		
		LCS = LongestCommonSubstring(buf1,buf2,buflen1,buflen2,IndexI,IndexJ);
	} else if (mxIsUint8(prhs[0]) || mxIsInt8(prhs[0]) || mxIsChar(prhs[0])) {
		char *buf1= (char*)mxGetData(prhs[0]);
		char *buf2= (char*)mxGetData(prhs[1]);
		LCS = LongestCommonSubstring(buf1,buf2,buflen1,buflen2,IndexI,IndexJ);
	}		

	const unsigned int dim_array[2] = {1,3};
	plhs[0] = mxCreateNumericArray(2,(const mwSize*)dim_array, mxDOUBLE_CLASS, mxREAL);
	double *buffer = (double*)mxGetPr(plhs[0]);
	buffer[0] = LCS;
	buffer[1] = IndexI;
 	buffer[2] = IndexJ;

	

}
