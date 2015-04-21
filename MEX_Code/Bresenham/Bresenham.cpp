#include <stdio.h>
#include <math.h>
#include "mex.h"

void line(double x0, double y0, double x1, double y1, double *mat,int NumLinesY,int NumLinesX,bool bSkipFirst ) {
   double dx = fabs(x1-x0);
   double dy = fabs(y1-y0);
   double sx = (x0 < x1) ? 1 : -1;
   double sy = (y0 < y1) ? 1 : -1;
   double err = dx-dy;

   while(1) {

     //setPixel(x0,y0)
	   if (bSkipFirst) {
		   bSkipFirst = false;
	   } else {
	   int index = x0*NumLinesY+ y0;
	   if (index >= 0 && index < NumLinesY*NumLinesX)
		mat[index]++;
	   else
	   {
		   assert(false);
		   int dbg = 1;
		   break;
	   }
	 }

     if ((x0 == x1) && (y0 == y1 ))
           break;
             
     double e2 = 2*err;
     if (e2 > -dy)  {
       err -= dy;
       x0 += sx;
     }
     if (e2 <  dx){
       err += dx;
       y0 += sy ;
     }
     }
}


void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {
    if (nrhs < 5)
	   return;

	double *WaveForms = (double*)mxGetData(prhs[0]);

	const int *dim = mxGetDimensions(prhs[0]);
	int NumWaveForms = dim[0];
	int NumPtsInWave = dim[1];

	double *afX = (double*)mxGetData(prhs[1]);
	int NumPtsX = (int) *(double*)mxGetData(prhs[2]);
	double *afY = (double*)mxGetData(prhs[3]);
	int NumPtsY = (int) *(double*)mxGetData(prhs[4]);
    
	// allocate the image
	mwSize dim1[2] = {NumPtsY,NumPtsX};
	plhs[0] = mxCreateNumericArray(2, dim1, mxDOUBLE_CLASS, mxREAL);
	
	double *LineHist = (double*)mxGetPr(plhs[0]);

	double fScaleX = 1.0/ (afX[1]-afX[0]) * (NumPtsX-1);
	double fScaleY = 1.0/ (afY[1]-afY[0]) * (NumPtsY-1);

	for (int WaveIter=0;WaveIter<NumWaveForms;WaveIter++) {
		
		for (int pt=0;pt<NumPtsInWave-1;pt++) {

			// Define line to draw:
			// Start point:
			double Ax = pt+1;
			assert(pt*NumWaveForms + WaveIter >= 0 && pt*NumWaveForms + WaveIter <  NumWaveForms*NumPtsInWave);
			assert((pt+1)*NumWaveForms + WaveIter >= 0 && (pt+1)*NumWaveForms + WaveIter <  NumWaveForms*NumPtsInWave);
			double Ay = WaveForms[pt*NumWaveForms + WaveIter];
			// End point
			double Bx = pt+2;
			double By = WaveForms[(pt+1)*NumWaveForms + WaveIter];
			// Now, convert those to coordinates in the image space...


			double Axt = (Ax-afX[0])* fScaleX;
			double Ayt = (Ay-afY[0])* fScaleY;
			double Bxt = (Bx-afX[0])* fScaleX;
			double Byt = (By-afY[0])* fScaleY;

			// Here come Bresenham!
			line((int)Axt, (int)Ayt,(int)Bxt,(int)Byt,LineHist, NumPtsY,NumPtsX,pt>0);


		}


	}

}