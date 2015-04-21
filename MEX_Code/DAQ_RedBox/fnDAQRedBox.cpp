#include <stdio.h>
#include "mex.h"
#include <math.h>
#include "cbw.h"
#include <mmsystem.h>
const int Pow2[15] = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192, 16384};
const int Pow2Rev[15] = {16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1};

int BoardNum=0;
const int EYE_X_PORT = 0; // hard wired for a faster implementation, but can always be acquired using GetAnalog command
const int EYE_Y_PORT = 1;

void fnSleep(double fWaitSecHighPerc) {

	LARGE_INTEGER prevTime;
	LARGE_INTEGER curTime;
	LARGE_INTEGER freqValue;
	double timeDifference;


	QueryPerformanceFrequency(&freqValue);
	QueryPerformanceCounter(&prevTime);

	while (1)
	{
		QueryPerformanceCounter(&curTime);
		timeDifference = curTime.QuadPart - prevTime.QuadPart;
		if (timeDifference / freqValue.QuadPart >= fWaitSecHighPerc )
			break;
	}     
}
void fnPrintUsage()
{
	mexPrintf("Usage:\n");
	mexPrintf("fnDAQ(command, param)\n");
	mexPrintf("\n");
	mexPrintf("Commands are: \n");
	mexPrintf("Init    [initializes ports, must call before any other function] \n");
	mexPrintf("SetBit(BitNumber [0,23], BitValue [0,1]) \n");
	mexPrintf("GetBit(BitNumber [0,23]) \n");
	mexPrintf("TTL(BitNumber [0,23], \n");
	mexPrintf("afValues = GetAnalog(aiChannels) \n");
		
	mexPrintf("\n");
	mexPrintf("\n");
	mexPrintf("More specific commands that are relevant for the to behavior machine:\n");
	mexPrintf("\n");
	mexPrintf("StrobeWord(Number 0..2^15-1),     [sends a 15 bit word, output bits are hard wired] \n");
	mexPrintf("\n");
}

void fnGetPortTypeAndFirstBit(int PortNumber,  int &PortType, int &FirstBit)
{
	switch (PortNumber) {
			 case 0:
				 PortType = FIRSTPORTA;
				 FirstBit = 0;
				 break;
			 case 1:
				 PortType = FIRSTPORTB;
				 FirstBit = 8;
				 break;
			 case 2:
				 PortType = FIRSTPORTCL;
				 FirstBit = 16;
				 break;
			 case 3:
				 PortType = FIRSTPORTCH;
				 FirstBit = 20;
				 break;
	}
}


void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	int ULStat,UDStat;

	if (nrhs < 1) {
		fnPrintUsage();
		return;
	}
	

	int StringLength = int(mxGetNumberOfElements(prhs[0])) + 1;
	char* Command = (char*)mxCalloc(StringLength, sizeof(char));

	if (mxGetString(prhs[0], Command, StringLength) != 0){
		mexErrMsgTxt("\nError extracting the command.\n");
		return;
	}

	if   (strcmp(Command, "StrobeWord") == 0) {
		/* get a user value to write to the port */
		int Number;
		if (mxIsDouble(prhs[1]))
			Number = int(*(double*)mxGetData(prhs[1]));
		else if (mxIsSingle(prhs[1]))
			Number = int(*(float*)mxGetData(prhs[1]));
		else if (mxIsUint8(prhs[1]))
			Number = int(*(char*)mxGetData(prhs[1]));
		else Number = 0;
		unsigned char LowByte = Number & 255;
		unsigned char HighByte = (Number >> 8) & 127; // Set strobe to zero

		ULStat = cbDOut(BoardNum, FIRSTPORTA, LowByte);
		ULStat = cbDOut(BoardNum, FIRSTPORTB, HighByte);
		ULStat = cbDBitOut (BoardNum, FIRSTPORTA, 15, 1); // Trigger strobe

		//Plexon Manual says Pulse width must be ? 250 ?sec.
        fnSleep(250 * 1e-6);

		//ULStat = cbDBitOut (BoardNum, FIRSTPORTA, 15, 0); 

		ULStat = cbDOut(BoardNum, FIRSTPORTA, 0);
		ULStat = cbDOut(BoardNum, FIRSTPORTB, 0);

		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = ULStat == NOERRORS;

 		return;
	} else if (strcmp(Command,"GetStatus") == 0) {
		short Status;
		long CurCount;
		long CurIndex;
		   unsigned Options;
 
		Options = CONVERTDATA + BACKGROUND;
		int LowChan = 0;
		int HighChan = 0;
		long Rate = 4;
	    int Gain = BIP10VOLTS;
	    WORD ADData[100];
		 long Count = 100;
 
	    //ULStat = cbAInScan (BoardNum, LowChan, HighChan, Count, &Rate,                        Gain, ADData, Options);
       ULStat = cbGetStatus (BoardNum, &Status, &CurCount, &CurIndex,AIFUNCTION);
    	
	   int dim[2] = {1,4};
		plhs[0] = mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
		double *MatlabData= (double*)mxGetPr(plhs[0]);
		MatlabData[0] = ULStat;
		MatlabData[1] = Status;
		MatlabData[2] = CurCount;
		MatlabData[3] = CurIndex;

	} else if (strcmp(Command, "GetAnalog") == 0) {

		const int *dim = mxGetDimensions(prhs[1]);
		double *Channels = (double*)mxGetData(prhs[1]);
		
		plhs[0] = mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
		int Gain = BIP10VOLTS;
		double *MatlabData= (double*)mxGetPr(plhs[0]);

		int NumElements = dim[0] > dim[1] ? dim[0] : dim[1];
		WORD Data;

		for (int iIter = 0; iIter< NumElements;iIter++) {
			int Channel = int(Channels[iIter]);
			UDStat = cbAIn (BoardNum, Channel, Gain, &Data);
			assert(UDStat == NOERRORS);
			MatlabData[iIter] = double(Data);
		}

	} else if (strcmp(Command, "Init") == 0) {
    	BoardNum = int(*(double*)mxGetData(prhs[1]));


		float    RevLevel = (float)CURRENTREVNUM;
		ULStat = cbDeclareRevision(&RevLevel);  
		//cbErrHandling (PRINTALL, DONTSTOP);
		
		bool bError = false;

		cbErrHandling (DONTPRINT, DONTSTOP);
        // Setup all digital ports to be "OUT"
		int ULStat1 = cbDConfigPort (BoardNum, FIRSTPORTA, DIGITALOUT);
		//assert(ULStat == NOERRORS);
		int ULStat2 = cbDConfigPort (BoardNum, FIRSTPORTB, DIGITALOUT);
		//assert(ULStat == NOERRORS);
		// Zero out all lines
		bError = ULStat1 != NOERRORS || ULStat2 != NOERRORS;

		for (int Bit=0;Bit<=15;Bit++)  {
			ULStat = cbDBitOut(BoardNum, FIRSTPORTA, Bit, 0);
			if (ULStat != NOERRORS) {
				bError = true;
				break;
			}
		}
		
		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = bError;

	} else if (strcmp(Command, "GetBit") == 0) {
		/* get a user value to write to the port */
		int BitNumber = int(*(double*)mxGetData(prhs[1]));
		USHORT BitValue;
		ULStat = cbDBitIn(BoardNum, FIRSTPORTA, BitNumber, &BitValue);
		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxLOGICAL_CLASS, mxREAL);
		unsigned char *Out = (unsigned char*)mxGetPr(plhs[0]);
		*Out = BitValue>0;

	} else if (strcmp(Command, "SetBit") == 0) {
		/* get a user value to write to the port */
		int BitNumber = int(*(double*)mxGetData(prhs[1]));
		bool BitValue = int(*(double*)mxGetData(prhs[2])) > 0;
		ULStat = cbDBitOut (BoardNum, FIRSTPORTA, BitNumber, BitValue);

		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = ULStat == NOERRORS;
		return;

	} else if (strcmp(Command, "TTL") == 0) {
		/* get a user value to write to the port. TTL Pulse is roughly 5 micro sec. Non blocking operation.... */
		int BitNumber = int(*(double*)mxGetData(prhs[1]));

		double fWidthSec = *(double*)mxGetData(prhs[2]);
		ULStat = cbDBitOut (BoardNum, FIRSTPORTA, BitNumber, 1);
        fnSleep(fWidthSec); 
		ULStat = cbDBitOut (BoardNum, FIRSTPORTA, BitNumber, 0);
		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = ULStat == NOERRORS;
		return;
	} else if (strcmp(Command, "SetByte") == 0) {
		  int PortNumber = int(*(double*)mxGetData(prhs[1]));
		  unsigned char DataByte= (unsigned char)(*(double*)mxGetData(prhs[2]));	

		  int PortType, FirstBit;
		  fnGetPortTypeAndFirstBit(PortNumber, PortType, FirstBit);

		  ULStat = cbDOut(BoardNum, PortType, DataByte);
		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = ULStat == NOERRORS;
	} else  {
		fnPrintUsage();
	}

}

