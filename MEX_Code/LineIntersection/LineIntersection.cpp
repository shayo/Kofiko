/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include <stdio.h>
#include <math.h>
#include "mex.h"
#define MAX(x,y)(x>y)?(x):(y)
#define MIN(x,y)(x<y)?(x):(y)


//  public domain function by Darel Rex Finley, 2006



//  Determines the intersection point of the line defined by points A and B with the
//  line defined by points C and D.
//
//  Returns YES if the intersection point was found, and stores that point in X,Y.
//  Returns NO if there is no determinable intersection point, in which case X,Y will
//  be unmodified.

void Cross(double x1, double y1, double z1, double x2, double y2, double z2, double &xo, double &yo, double &zo) {
xo = y1*z2-z1*y2;
yo = z1*x2-x1*z2;
zo = x1*y2-y1*x2;
}

bool lineIntersection(
double Ax, double Ay,
double Bx, double By,
double Cx, double Cy,
double Dx, double Dy) {

	if ((Ax == Bx && Ay == By) || (Cx == Dx && Cy == Dy ))
		return false;
  // Use Homogenous representation...
	double L1x,L1y,L1z;
	Cross(Ax, Ay, 1, Bx, By, 1,L1x,L1y,L1z); 

	double L2x,L2y,L2z;
	Cross(Cx, Cy, 1, Dx, Dy, 1,L2x,L2y,L2z); 

	double Ix, Iy, Iz; // Intersection Point...

	Cross(L1x,L1y,L1z, L2x,L2y,L2z, Ix,Iy,Iz); 

	// Represent intersection point in Line 1
	if (Iz == 0)
		return false;  // Imaginary point at infinity... Lines are parallel.

	double x = Ix/Iz;
	double y = Iy/Iz;

	double t1,t2;
	
	if (Ax==Bx) 
		t1 = (y -Ay)/(By-Ay);
	else
		// Ax + t * (Bx-Ax) = x -> t = (x-Ax) / (Bx-Ax)
		t1 = (x -Ax)/(Bx-Ax);
	
	
	if (Cx==Dx) 
		t2 = (y -Cy)/(Dy-Cy);
	else
		// Ax + t * (Bx-Ax) = x -> t = (x-Ax) / (Bx-Ax)
		t2 = (x -Cx)/(Dx-Cx);

  
  return (t1 >=0 && t1 <= 1 && t2 >= 0 && t2 <= 1); 
}

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
	if (nrhs < 2)
		return;

	double *WaveForms = (double*)mxGetData(prhs[0]);
	double *LineSegment = (double*)mxGetData(prhs[1]);

	const int *dim = mxGetDimensions(prhs[0]);
	int NumWaveForms = dim[0];
	int NumPtsInWave = dim[1];
	mwSize     dim1[2] = {1,NumWaveForms};
	plhs[0] = mxCreateNumericArray(2, dim1, mxLOGICAL_CLASS, mxREAL);
	bool *Intersect = (bool*)mxGetPr(plhs[0]);

	for (int WaveIter=0;WaveIter<NumWaveForms;WaveIter++) {

		Intersect[WaveIter] = false;
		for (int pt=0;pt<NumPtsInWave-1;pt++) {
			double Cx = pt+1;
			double Cy = WaveForms[pt*NumWaveForms + WaveIter];
			double Dx = pt+2;
			double Dy = WaveForms[(pt+1)*NumWaveForms + WaveIter];
			if (lineIntersection(LineSegment[0],LineSegment[1],LineSegment[2],LineSegment[3],Cx,Cy,Dx,Dy )) {
				Intersect[WaveIter] = true;
				break;
			}
			
		}
	}
    
	return;
}
