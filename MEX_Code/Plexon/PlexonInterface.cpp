//#define _AFXDLL


//#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include "plexon.h"
#include "mex.h"
#include <assert.h>


#define MAX_MAP_EVENTS_PER_READ 500000
             //** loop counter



void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

				 
int MAPSampleRate = 40000;
PL_Event*     pServerEventBuffer;     //** buffer in which the Server will return MAP events
  int           NumMAPEvents;           //** number of MAP events returned from the Server
  int           NumSpikeTimestamps;     //** number of MAP events which are spike timestamps
  int           i;         
	int StringLength = int(mxGetNumberOfElements(prhs[0])) + 1;
	char* Command = (char*)mxCalloc(StringLength, sizeof(char));

	if (mxGetString(prhs[0], Command, StringLength) != 0){
		mexErrMsgTxt("\nError extracting the command.\n");
		return;
	}
	if   (strcmp(Command, "Init") == 0) {
		PL_InitClientEx3(0, NULL, NULL);
	
	} else if   (strcmp(Command, "ReadData") == 0){
		
		pServerEventBuffer = (PL_Event*)malloc(sizeof(PL_Event)*MAX_MAP_EVENTS_PER_READ);

		NumMAPEvents = MAX_MAP_EVENTS_PER_READ;

	
    //** this tells the Server the max number of MAP events that can be returned to us in one read
    NumMAPEvents = MAX_MAP_EVENTS_PER_READ;

    //** call the Server to get all the MAP events since the last time we called PL_GetTimeStampStructures
	  PL_GetTimeStampStructures(&NumMAPEvents, pServerEventBuffer);
	for (int MAPEventIndex = 0; MAPEventIndex < NumMAPEvents; MAPEventIndex++){ 
    //** step through the array of MAP events, counting only the spike timestamps
    NumSpikeTimestamps = 0; //** reset counts
    for (i = 0; i < NumMAPEvents; i++)
    {
      //** is this the timestamp of a sorted spike?
      if (pServerEventBuffer[i].Type == PL_SingleWFType && //** spike timestamp
          pServerEventBuffer[i].Unit >= 1 &&               //** 1,2,3,4 = a,b,c,d units
          pServerEventBuffer[i].Unit <= 4)                 //** unsorted spikes have Unit == 0
        NumSpikeTimestamps++;
    }
}
}
}