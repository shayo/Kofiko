/*
% Copyright (c) 2012 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include "nr3.h"
#include "eigen_sym.h"
#include <stdio.h>
#include <string>
#include "mex.h"
#include <math.h>
/*******************************/

class Line {
public:
	Line();
	bool WaveFormIntersect(double *WaveForm, int n);
	int x1,y1,x2,y2;
	void Cross(double x1, double y1, double z1, double x2, double y2, double z2, double &xo, double &yo, double &zo) ;
	bool SegmentIntersection(double Ax, double Ay,double Bx, double By,double Cx, double Cy,double Dx, double Dy);
};

bool Line::WaveFormIntersect(double *WaveForm, int n) {
	for (int pt=0;pt<n-1;pt++) {
			double Cx = pt;
			double Cy = WaveForm[pt];
			double Dx = pt+1;
			double Dy = WaveForm[(pt+1)];
			if (SegmentIntersection(x1,y1,x2,y2, Cx,Cy,Dx,Dy ))
				return true;
	}
	return false;
}

Line::Line() {
}



void Line::Cross(double x1, double y1, double z1, double x2, double y2, double z2, double &xo, double &yo, double &zo) {
xo = y1*z2-z1*y2;
yo = z1*x2-x1*z2;
zo = x1*y2-y1*x2;
}

bool Line::SegmentIntersection(double Ax, double Ay,double Bx, double By,double Cx, double Cy,double Dx, double Dy) {

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


class Region {
public:
	Region();
	bool InsideRegion(int _x, int _y);
	
	int n;
	int *x,*y;
};
Region::Region() {
}

bool Region::InsideRegion(int _x, int _y) {
	return false;
}
/*****************************/
const int MAX_LINES = 10;
const int MAX_UNITS_PER_CHANNEL = 20;
const int SORT_LINES = 0;

class SpikeSort {
public:
	SpikeSort();

	bool SortWaveForm(double *WaveForm, int n);

	void SetSortMethod(int _Method);
	int AddLine(int x1, int y1, int x2, int y2);
	void RemoveLine(int iLineIndex);
	void SetPCARegion(int N, int *x, int *y);
	void ModifyPCARegion(int N, int *x, int *y);

	int Method;
	Region region;
	Line lines[MAX_LINES];
	int NumLines;
	int UniqueID;
	int Color[3];
};

void SpikeSort::RemoveLine(int iLineIndex) {
	if (iLineIndex < 0 || NumLines == 0)
		return;
		
	lines[iLineIndex] = lines[NumLines];
	NumLines--;
	
}
	

int SpikeSort::AddLine(int x1, int y1, int x2, int y2) {
	lines[NumLines].x1 = x1;
	lines[NumLines].y1 = y1;
	lines[NumLines].x2 = x2;
	lines[NumLines].y2 = y2;
	NumLines++;
	return NumLines-1;
}

SpikeSort::SpikeSort() {
}

void SpikeSort::SetSortMethod(int _Method) {
	Method = _Method;
}

bool SpikeSort::SortWaveForm(double *WaveForm, int n) {
	if (Method == SORT_LINES) {
		// Lines
		bool bIntersect = true;
		for (int k=0;k<NumLines;k++)
			bIntersect &= lines[k].WaveFormIntersect(WaveForm,n);
		return bIntersect;

	} else if (Method == 1) {
		// PCA
	} else if (Method == 2) {
		// KlustaKwik!

	} // else ?
	return false;
}

/********************************/

class CircularChannelBuffer {
public:
	CircularChannelBuffer();
	void Allocate(int _BufferLength, int _WaveFormLength);
	int AddWaveFormAndSort(double *WaveForm);
	void Clear();
	void PCA_Buffer();

	double *Mean;
	double *PCA1, *PCA2;

	int BufferLength,  WaveFormLength;
	int **Buf;
	int *Assignment;
	int Pos;
	int NumSamplesAvail;

	bool AddActiveUnitUsingLineMethod(int UniqueID, int x1, int y1, int x2, int y2);
	bool RemoveUnit(int UniqueID);
	SpikeSort ActiveUnits[MAX_UNITS_PER_CHANNEL];
	int NumActiveUnits;
};

bool CircularChannelBuffer::RemoveUnit(int UniqueID) {
	for (int k=0;k<NumActiveUnits;k++) {
		if (ActiveUnits[k].UniqueID == UniqueID) {
			// remove k'th unit
			for (int j=k+1;j<NumActiveUnits;j++) {
				ActiveUnits[j-1] = ActiveUnits[j];
			}
			NumActiveUnits--;
			return true;
		}
	}
	return false;
}

typedef double* pdouble;

void CircularChannelBuffer::PCA_Buffer() {
	// 1. Subtract the mean
	// 2. Compute Covariance
	// 3. Compute Eigen vectors
	// 4. Sort Them..

	for (int k=0;k<WaveFormLength;k++)
		Mean[k] = 0;

	// compute the mean
	for (int iSampleIter=0;iSampleIter<NumSamplesAvail;iSampleIter++) {
		for (int k=0;k<WaveFormLength;k++) {
			Mean[k] += double(Buf[iSampleIter][k]) / double(NumSamplesAvail);
		}
	}
	// fill in the covariance matrix....
	MatDoub_O Cov(WaveFormLength,WaveFormLength);
	for (int i=0;i<WaveFormLength;i++) {
		for (int j=0;j<WaveFormLength;j++) {

			double tmp=0;
			for (int k=0;k<NumSamplesAvail;k++) {
				tmp += (double(Buf[k][i])-Mean[i]) * (double(Buf[k][j])-Mean[j]);
			}

			Cov[i][j] = tmp;
			Cov[j][i] = Cov[i][j];
		}
	}

	// compute eigen vectors

	Jacobi J(Cov);
	for (int k=0;k<WaveFormLength;k++) {
		PCA1[k] = J.v[k][0];
		PCA2[k] = J.v[k][1];
	}
}

bool CircularChannelBuffer::AddActiveUnitUsingLineMethod(int UniqueID, int x1, int y1, int x2, int y2) {
	if (NumActiveUnits >= MAX_UNITS_PER_CHANNEL)
		return false;

	ActiveUnits[NumActiveUnits].SetSortMethod(SORT_LINES);
	ActiveUnits[NumActiveUnits].AddLine(x1,y1,x2,y2);
	ActiveUnits[NumActiveUnits].UniqueID = UniqueID;
	NumActiveUnits++;
	return true;
}

CircularChannelBuffer::CircularChannelBuffer() {
	Buf = NULL;
	Assignment = NULL;
	NumActiveUnits = 0;
}

void CircularChannelBuffer::Clear() {
	Pos = 0;
	NumSamplesAvail = 0;
}

int CircularChannelBuffer::AddWaveFormAndSort(double *WaveForm) {
	// Apply spike sorting....
	int UnitAssignment = 0;

	for (int k=0;k<NumActiveUnits;k++) {
		if (ActiveUnits[k].SortWaveForm(WaveForm, WaveFormLength)) {
			UnitAssignment = ActiveUnits[k].UniqueID;
			break;
		}
	}

	// Store in circular memory

	Assignment[Pos] = UnitAssignment;
	for (int k=0;k<WaveFormLength;k++) {
		assert(Pos*WaveFormLength + k >= 0 && Pos*WaveFormLength + k < WaveFormLength*BufferLength);
		Buf[Pos][k] = (int) WaveForm[k];
	}
	Pos++;
	NumSamplesAvail++;
	if (Pos >= BufferLength) {
		NumSamplesAvail = BufferLength;
		Pos = 0;
	}

	// return assignment
	return UnitAssignment;
}

typedef int* pint;
void CircularChannelBuffer::Allocate(int _BufferLength, int _WaveFormLength){
	if (Buf != NULL) {
		for (int k=0;k<BufferLength;k++) {
			delete [] Buf[k];
		}
		delete Buf;
		delete [] Assignment;
		delete [] PCA1;
		delete [] PCA2;
		delete [] Mean; 
	}

	BufferLength = _BufferLength;
	WaveFormLength = _WaveFormLength;

	Pos = 0;
	NumSamplesAvail = 0;
	Buf = new pint[BufferLength];
	for (int k=0;k<BufferLength;k++) {
		Buf[k]= new int[WaveFormLength];
	}
	Mean = new double[WaveFormLength];
	PCA1 = new double[WaveFormLength];
	PCA2 = new double[WaveFormLength];

	Assignment = new int[BufferLength];
	for (int k=0;k<BufferLength;k++)
		Assignment[k] = 0;
	for (int k=0;k<WaveFormLength;k++) {
		Mean[k]=PCA1[k]=PCA2[k]=0;
	}
}
/*************************************************/

class ChannelsBuffer {
public:
	ChannelsBuffer(int _NumCh, int _BufferLength, int _WaveFormLength);
	int AddWaveFormToChannel(int Channel, double *WaveForm);
	void ClearChannelBuffer(int Channel);
	int GetNumSamplesInBuffer(int Channel);
	int NumCh;
	int BufferLength,  WaveFormLength;
	CircularChannelBuffer* pChannelsBuffer;
};

int ChannelsBuffer::GetNumSamplesInBuffer(int Channel) {
	return pChannelsBuffer[Channel-1].NumSamplesAvail;
}

void ChannelsBuffer::ClearChannelBuffer(int Channel) {
	pChannelsBuffer[Channel-1].Clear();
}

ChannelsBuffer::ChannelsBuffer(int _NumCh, int _BufferLength, int _WaveFormLength) {
	NumCh = _NumCh;
	BufferLength = _BufferLength;
	WaveFormLength = _WaveFormLength;

	pChannelsBuffer = new CircularChannelBuffer[NumCh];
	for (int k=0;k<NumCh;k++) {
		pChannelsBuffer[k].Allocate(BufferLength, WaveFormLength);
	}
}

int ChannelsBuffer::AddWaveFormToChannel(int Channel, double *WaveForm) {
	return pChannelsBuffer[Channel-1].AddWaveFormAndSort(WaveForm);
}

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
	static char buff[80+1];
	buff[0]=0;
	mxGetString(prhs[0],buff,80);


	if (strcmp(buff,"Init") == 0) {
		int NumChannels = (int)*(double*)mxGetData(prhs[1]);
		int BufLength = (int)*(double*)mxGetData(prhs[2]);
		int NumDataPoints = (int)*(double*)mxGetData(prhs[3]);
		ChannelsBuffer *pBuf = new ChannelsBuffer(NumChannels, BufLength, NumDataPoints);
		double *pp = (double*)&pBuf;

		plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
		double *pOut= mxGetPr(plhs[0]);
		*pOut = *pp;
		return;
	}	
	if (strcmp(buff,"Update") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		
		double *aiChannels = (double*)mxGetData(prhs[2]);
		double *pWaves= (double*)mxGetData(prhs[3]);
		int NumEntries = (int)mxGetNumberOfElements(prhs[2]);

		int dim_wave_out[2] ={1, NumEntries};
		plhs[0] = mxCreateNumericArray(2, dim_wave_out, mxDOUBLE_CLASS, mxREAL);
		double *pAssignment = (double*)mxGetPr(plhs[0]);

		for (int i=0;i<NumEntries;i++) {
			if (aiChannels[i] >= 1 && aiChannels[i] <= pBuf->NumCh) {
				pAssignment[i] = pBuf->AddWaveFormToChannel((int)aiChannels[i], pWaves+i*pBuf->WaveFormLength);
			} else {
				assert(false);
			}
		}
	}

	if (strcmp(buff,"Clear") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		double *aiChannels = (double*)mxGetData(prhs[2]);
		int NumEntries = (int)mxGetNumberOfElements(prhs[2]);
		for (int i=0;i<NumEntries;i++) {
			if (aiChannels[i] >= 1 && aiChannels[i] <= pBuf->NumCh) {
				pBuf->ClearChannelBuffer((int)aiChannels[i]);
			}
		}
	}

	if (strcmp(buff,"GetBuffer") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		if (Channel >= 1 && Channel <= pBuf->NumCh) {

			int NumSamplesAvail = pBuf->GetNumSamplesInBuffer(Channel);

			// 1. Return Wave forms.
			int dim_wave_out[2] ={pBuf->WaveFormLength, NumSamplesAvail};
			plhs[0] = mxCreateNumericArray(2, dim_wave_out, mxDOUBLE_CLASS, mxREAL);
			double *pOut= (double*)mxGetPr(plhs[0]);

			int c = 0;
			int p = pBuf->pChannelsBuffer[Channel-1].Pos;

			for (int k=0;k<NumSamplesAvail;k++) {
				int Pos = (p-NumSamplesAvail+k) < 0 ? NumSamplesAvail+(p-NumSamplesAvail+k) : (p-NumSamplesAvail+k);
				for (int j=0;j<pBuf->WaveFormLength;j++) {
					assert(Pos >= 0 && Pos < NumSamplesAvail);
					pOut[c++] = pBuf->pChannelsBuffer[Channel-1].Buf[Pos][j]; 
				}
			}
			// 2. return unit association & PCA
			int dim_unit_out[2] ={1, NumSamplesAvail};
			plhs[1] = mxCreateNumericArray(2, dim_unit_out, mxDOUBLE_CLASS, mxREAL);
			double *pOutUnit= (double*)mxGetPr(plhs[1]);
			int dim_pca_out[2] ={2, NumSamplesAvail};
			plhs[2] = mxCreateNumericArray(2, dim_pca_out, mxDOUBLE_CLASS, mxREAL);
			double *pPCAOut= (double*)mxGetPr(plhs[2]);
			for (int k=0;k<NumSamplesAvail;k++) {
				int Pos = (p-NumSamplesAvail+k) < 0 ? NumSamplesAvail+(p-NumSamplesAvail+k) : (p-NumSamplesAvail+k);
				pOutUnit[k]=pBuf->pChannelsBuffer[Channel-1].Assignment[Pos];

				// compute PCA projection
				double fPCA1=0,fPCA2 = 0;
				for (int i=0;i<pBuf->WaveFormLength;i++) {
					fPCA1+=(pBuf->pChannelsBuffer[Channel-1].Buf[Pos][i]-pBuf->pChannelsBuffer[Channel-1].Mean[i]) * pBuf->pChannelsBuffer[Channel-1].PCA1[i];
					fPCA2+=(pBuf->pChannelsBuffer[Channel-1].Buf[Pos][i]-pBuf->pChannelsBuffer[Channel-1].Mean[i]) * pBuf->pChannelsBuffer[Channel-1].PCA2[i];
				}

				pPCAOut[k]= fPCA1;
				pPCAOut[k+NumSamplesAvail]= fPCA2;
			}


		}
	
	}


	if (strcmp(buff,"RunPCA") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		pBuf->pChannelsBuffer[Channel-1].PCA_Buffer();

		// return result...
		int dim_out[2] ={pBuf->WaveFormLength,2};
		plhs[0] = mxCreateNumericArray(2, dim_out, mxDOUBLE_CLASS, mxREAL);
		
		double *pOut= (double*)mxGetPr(plhs[0]);
		for (int j=0;j<pBuf->WaveFormLength;j++) {
			pOut[j]=pBuf->pChannelsBuffer[Channel-1].PCA1[j];
			pOut[j+pBuf->WaveFormLength]=pBuf->pChannelsBuffer[Channel-1].PCA2[j];
		}

		int dim_out_mean[2] ={1,pBuf->WaveFormLength};
		plhs[1] = mxCreateNumericArray(2, dim_out_mean, mxDOUBLE_CLASS, mxREAL);
		double *pOutMean= (double*)mxGetPr(plhs[1]);
		for (int j=0;j<pBuf->WaveFormLength;j++) {
			pOutMean[j]=pBuf->pChannelsBuffer[Channel-1].Mean[j];
		}

	

	}

	if (strcmp(buff,"AddActiveUnitLine") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		int UniqueID = (int)*(double*)mxGetData(prhs[3]);
		int x1 = (int)*(double*)mxGetData(prhs[4]);
		int y1 = (int)*(double*)mxGetData(prhs[5]);
		int x2 = (int)*(double*)mxGetData(prhs[6]);
		int y2 = (int)*(double*)mxGetData(prhs[7]);

		pBuf->pChannelsBuffer[Channel-1].AddActiveUnitUsingLineMethod(UniqueID, x1,y1,x2,y2);
	}

	if (strcmp(buff,"AddLineToExistingUnit") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		int UniqueID = (int)*(double*)mxGetData(prhs[3]);
		int x1 = (int)*(double*)mxGetData(prhs[4]);
		int y1 = (int)*(double*)mxGetData(prhs[5]);
		int x2 = (int)*(double*)mxGetData(prhs[6]);
		int y2 = (int)*(double*)mxGetData(prhs[7]);
		for (int k=0;k<pBuf->pChannelsBuffer[Channel-1].NumActiveUnits;k++) {
			if (pBuf->pChannelsBuffer[Channel-1].ActiveUnits[k].UniqueID == UniqueID) {
				break;
				pBuf->pChannelsBuffer[Channel-1].ActiveUnits[k].AddLine(x1,y1,x2,y2);
			}
		}
	}

	if (strcmp(buff,"RemoveLineFromExistingUnit") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		int UniqueID = (int)*(double*)mxGetData(prhs[3]);
		int iLineID = (int)*(double*)mxGetData(prhs[4]);

		for (int k=0;k<pBuf->pChannelsBuffer[Channel-1].NumActiveUnits;k++) {
			if (pBuf->pChannelsBuffer[Channel-1].ActiveUnits[k].UniqueID == UniqueID) {
				pBuf->pChannelsBuffer[Channel-1].ActiveUnits[k].RemoveLine(iLineID);
				break;
			}
		}
	}

	if (strcmp(buff,"RemoveActiveUnit") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		int UniqueID = (int)*(double*)mxGetData(prhs[3]);
		for (int k=0;k<pBuf->pChannelsBuffer[Channel-1].NumActiveUnits;k++) {
			if (pBuf->pChannelsBuffer[Channel-1].ActiveUnits[k].UniqueID == UniqueID) {
				pBuf->pChannelsBuffer[Channel-1].RemoveUnit(k);
				
				break;
			}
		}
	}



	if (strcmp(buff,"AddActiveUnitPCAPolygon") == 0) {
		ChannelsBuffer *pBuf = *(ChannelsBuffer **)(void*)(double*)mxGetData(prhs[1]);
		int Channel = (int)*(double*)mxGetData(prhs[2]);
		int UniqueID = (int)*(double*)mxGetData(prhs[3]);
		double *x = *(double*)mxGetData(prhs[4]);
		double *y = *(double*)mxGetData(prhs[5]);

		pBuf->pChannelsBuffer[Channel-1].AddActiveUnitUsingLineMethod(UniqueID, x1,y1,x2,y2);
	}

}
