//strobetesting

#include <stdio.h>
#include "mex.h"
#include <math.h>
#include "math.h"
#include <stdint.h>
#include "stdint.h"
#include <windows.h>
#include <mmsystem.h>
#include "NIDAQmx.h"
#include <string>
#include <assert.h>
#include <cstdint>

using namespace std;

int BoardNum=0;
const int EYE_X_PORT = 0; // hard wired for a faster implementation, but can always be acquired using GetAnalog command
const int EYE_Y_PORT = 1;
static TaskHandle digitalTasks[24] = {0};
static TaskHandle analogTasks[16] = {0};
string dolines [24] = {"Dev1/port0/line0", "Dev1/port0/line1", "Dev1/port0/line2", "Dev1/port0/line3", "Dev1/port0/line4", "Dev1/port0/line5", "Dev1/port0/line6", "Dev1/port0/line7", "Dev1/port1/line0", "Dev1/port1/line1", "Dev1/port1/line2", "Dev1/port1/line3", "Dev1/port1/line4", "Dev1/port1/line5", "Dev1/port1/line6", "Dev1/port1/line7", "Dev1/port2/line0", "Dev1/port2/line1", "Dev1/port2/line2", "Dev1/port2/line3", "Dev1/port2/line4", "Dev1/port2/line5", "Dev1/port2/line6", "Dev1/port2/line7"}; // string names that refer to each digital line
//string dolines [2] = {'Dev1/port2/line6', 'Dev1/port2/line7'}; // string names that refer to each digital line
string anlines [16] = {"Dev1/ai0", "Dev1/ai1", "Dev1/ai2", "Dev1/ai3", "Dev1/ai4", "Dev1/ai5", "Dev1/ai6", "Dev1/ai7", "Dev1/ai8", "Dev1/ai9", "Dev1/ai10", "Dev1/ai11", "Dev1/ai12", "Dev1/ai13", "Dev1/ai14", "Dev1/ai15"}; // string names for each analog input
const uInt8 negOne [1] = {-1};
const uInt8 zero [1] = {0};
const uInt8 one [1] = {1};
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
		//mexPrintf("%d",Number);
		//mexPrintf("\n");
		unsigned char LowByte = Number & 255;
		unsigned char HighByte = (Number >> 8) & 127; // Set strobe to zero
		
		//int LowByte = {Number & 255};
		//mexPrintf("%d",LowByte);
		//mexPrintf("\n");
		//int HighByte = {(Number >> 8) };//& 127};
		//mexPrintf("%d",HighByte);
		//mexPrintf("\n");
		//uInt8 x [1]= {};
		//uint8_t *bit = new uint8_t;//[LowByte.size()+1];
		string bits = dec2bin(Number);
		//unsigned char *bits2=new unsigned char[bits.size()+1];
		uInt8 *bits2=new unsigned char[bits.size()+1];
		bits2[bits.size()]=0;
		memcpy(bits2,bits.c_str(),bits.size());
		DAQmx_Val_AllowRegen;
		//mexPrintf("bits2 = %s",bits2);
		ULStat = DAQmxWriteDigitalScalarU32(digitalTasks[0], 1, -1, uInt16(1), NULL);
		for(int k = 0; k < 16; k++){
			//mexPrintf("\n");
			//mexPrintf("%d",bits2[k]-48);
			uInt8 *x = new uInt8 [16];//  bits2[k]-48;
			x = bits2;
			//mexPrintf("%d",x[k]-48);
			//mexPrintf("\n");
			uInt32 bit [1] = {x[k]-48};
			mexPrintf("\n");
			mexPrintf("write %d to channel %d",bit[0],k+8);
			ULStat = DAQmxWriteDigitalScalarU32(digitalTasks[k+8], 1, 1, bit[0], NULL);
			//ULStat = DAQmxWriteDigitalLines(digitalTasks[k+8], 1, true, -1, DAQmx_Val_GroupByChannel, bit[0], NULL, NULL);
			//mexPrintf("channel %d assigned bit %d",k+8,&bits2[k]);
		}
		//for(int k = 8; k < 24; k++){
			//mexPrintf("%d",k);
			//x[0] = LowByte & Pow2[k];
			//---------------------
			
			//a[dolines[k].size()]=0;
			//memcpy(bit,LowByte,LowByte.size());
			
			//---------------------
			//bit [8] = LowByte & Pow2[k-8];
			//uint8_t bit [1] = {LowByte};//{LowByte >>(k-8)};
			
			//mexPrintf("%d",bit[k-8]);
			//mexPrintf("\n");
			//mexPrintf("afValues = GetAnalog(aiChannels) \n");
       		//ULStat = DAQmxWriteDigitalLines(digitalTasks[k], 1, true, -1, DAQmx_Val_GroupByChannel, bit[k-8], NULL, NULL);
		//}
		//for(int k = 16; k < 24; k++){
			//x[0] = HighByte & Pow2[k];
			//uInt8 bit [1] = {HighByte & Pow2[k - 16]};
			//int shift = HighByte >> k - 16
			//uint8_t bit [1] = {HighByte};// {HighByte >>(k - 16)};
			//mexPrintf("%d",bit);
			//mexPrintf("\n");
       		//ULStat = DAQmxWriteDigitalLines(digitalTasks[k], 1, true, -1, DAQmx_Val_GroupByChannel, bit, NULL, NULL);
		//}
		//uInt8 bit [1] = {1};
		//ULStat = DAQmxWriteDigitalLines(digitalTasks[0], 1, true, -1, DAQmx_Val_GroupByChannel, one, NULL, NULL); // Trigger strobe

		//Plexon Manual says Pulse width must be ≥ 250 μsec.
        fnSleep(250 * 1e-6);

		//ULStat = cbDBitOut (BoardNum, FIRSTPORTA, 15, 0); 
		
		for(int k = 8; k < 24; k++){
       		ULStat = DAQmxWriteDigitalLines(digitalTasks[k], 1, true, -1, DAQmx_Val_GroupByChannel, zero, NULL, NULL);
		}
		ULStat = DAQmxWriteDigitalLines(digitalTasks[0], 1, true, -1, DAQmx_Val_GroupByChannel, zero, NULL, NULL);
		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = ULStat == 0;

 		return;
	} else if (strcmp(Command, "GetAnalog") == 0) {

		const int *dim = mxGetDimensions(prhs[1]);

		double *Channels = (double*)mxGetData(prhs[1]);
		
		plhs[0] = mxCreateNumericArray(2, dim, mxDOUBLE_CLASS, mxREAL);
		double *MatlabData= (double*)mxGetPr(plhs[0]);

		int NumElements = dim[0] > dim[1] ? dim[0] : dim[1];
		float64 Data;

		for (int iIter = 0; iIter< NumElements;iIter++) {
			int Channel = int(Channels[iIter]);
			// assume +- 5V
			
			UDStat = DAQmxReadAnalogScalarF64(analogTasks[Channel], -1, &Data, NULL);
			assert(UDStat == 0);
			MatlabData[iIter] = double(Data);
		}

	} else if (strcmp(Command, "Init") == 0) {

		BoardNum = int(*(double*)mxGetData(prhs[1]));
		uInt8 zeroBit [1] = {0};
		// For each line on each port, create a task, assign a DO channel to it, and zero it.
		for(int k=0; k<24; k++) {
		
			// Convert the string to a char array so we can feed it to the NI function
			char *a=new char[dolines[k].size()+1];
			a[dolines[k].size()]=0;
			memcpy(a,dolines[k].c_str(),dolines[k].size());
			
			DAQmxCreateTask("",&(digitalTasks[k]));
			DAQmxCreateDOChan(digitalTasks[k], a, NULL, DAQmx_Val_ChanPerLine);
			DAQmxStartTask(digitalTasks[k]);
			DAQmxWriteDigitalLines(digitalTasks[k], 1, true, -1, DAQmx_Val_GroupByChannel, zero, NULL, NULL);
		}

		// Assign each analog input to a task
		for(int n=0; n<16; n++){
			
			// Convert the string to a char array so we can feed it to the NI function
			char *a=new char[anlines[n].size()+1];
			a[anlines[n].size()]=0;
			memcpy(a,anlines[n].c_str(),anlines[n].size());
			
			
			DAQmxCreateTask("", &(analogTasks[n]));
			DAQmxCreateAIVoltageChan(analogTasks[n], a, NULL, DAQmx_Val_RSE, -5, 5, DAQmx_Val_Volts, NULL);
		}

		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out = (double*)mxGetPr(plhs[0]);
		*Out = 0;

	} else if (strcmp(Command, "SetBit") == 0) {
		/* get a user value to write to the port */
		int BitNumber = int(*(double*)mxGetData(prhs[1]));
		uInt8 BitValue [1]= {int(*(double*)mxGetData(prhs[2])) > 0};
		ULStat = DAQmxWriteDigitalLines(digitalTasks[BitNumber], 1, true, -1, DAQmx_Val_GroupByChannel, BitValue, NULL, NULL);
		int dim[1] = {1};
		plhs[0] = mxCreateNumericArray(1, dim, mxDOUBLE_CLASS, mxREAL);
		double *Out  =(double*)mxGetPr(plhs[0]);
		*Out = ULStat == 0;
		return;

	} 
	} 
	} 

}

		for(int k = 0; k < 16; k++){
			//mexPrintf("\n");
			//mexPrintf("%d",bits2[k]-48);
			uInt8 *x = new uInt8 [16];//  bits2[k]-48;
			x = bits2;
			//mexPrintf("%d",x[k]-48);
			//mexPrintf("\n");
			uInt32 bit [1] = {x[k]-48};
			//mexPrintf("\n");
			mexPrintf("write %d to channel %d",bit[0],k+8);
			//ULStat = DAQmxWriteDigitalScalarU32(digitalTasks[k+8], 1, 1, bit[0], NULL);
			//ULStat = DAQmxWriteDigitalLines(digitalTasks[k+8], 1, true, -1, DAQmx_Val_GroupByChannel, bit[0], NULL, NULL);
			//mexPrintf("channel %d assigned bit %d",k+8,&bits2[k]);
		}
		
		//mexPrintf("%d",k);
			//x[0] = LowByte & Pow2[k];
			//---------------------
			
			//a[dolines[k].size()]=0;
			//memcpy(bit,LowByte,LowByte.size());
			
			//---------------------
			//bit [8] = LowByte & Pow2[k-8];
			//uint8_t bit [1] = {LowByte};//{LowByte >>(k-8)};
			
			//mexPrintf("%d",bit[k-8]);
			//mexPrintf("\n");
			//mexPrintf("afValues = GetAnalog(aiChannels) \n");
			//ULStat = setBitForStrobeword(k, )
			
			
			//for(int k = 16; k < 24; k++){
			//x[0] = HighByte & Pow2[k];
			//uInt8 bit [1] = {HighByte & Pow2[k - 16]};
			//int shift = HighByte >> k - 16
			//uint8_t bit [1] = {HighByte};// {HighByte >>(k - 16)};
			//mexPrintf("%d",bit);
			//mexPrintf("\n");
       		//ULStat = DAQmxWriteDigitalLines(digitalTasks[k], 1, true, -1, DAQmx_Val_GroupByChannel, bit, NULL, NULL);
		//}
		//uInt8 bit [1] = {1};