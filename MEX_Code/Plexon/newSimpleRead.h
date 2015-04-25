//
//   SimpleRead.cpp 
//
//   (c) 1999-2012 Plexon Inc. Dallas Texas 75206 
//   www.plexoninc.com
//
//   Simple console-mode app that reads spike timestamps from the Server 
//   and prints a count of timestamps to the console window.  
//
//   Built using Microsoft Visual C++ 8.0.  Must include Plexon.h and link with PlexClient.lib.
//
//   See SampleClients.rtf for more information.
//

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <windows.h>
#include "mex.h"
//** header file containing the Plexon APIs (link with PlexClient.lib, run with PlexClient.dll)
#include "../../include/plexon.h"

//** maximum number of MAP events to be read at one time from the Server
#define MAX_MAP_EVENTS_PER_READ 500000


//int main(int argc, char* argv[])
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) {

  PL_Event*     pServerEventBuffer;     //** buffer in which the Server will return MAP events
  int           NumMAPEvents;           //** number of MAP events returned from the Server
  int           NumSpikeTimestamps;     //** number of MAP events which are spike timestamps
  int           i;                      //** loop counter

  //** connect to the server
  int h = PL_InitClientEx3(0, NULL, NULL);

  //** allocate memory in which the server will return MAP events
  pServerEventBuffer = (PL_Event*)malloc(sizeof(PL_Event)*MAX_MAP_EVENTS_PER_READ);
  if (pServerEventBuffer == NULL)
  {
    printf("Couldn't allocate memory, I can't continue!\r\n");
    Sleep(3000); //** pause before console window closes
    return 0;
  }

  //** this loop reads from the Server once per second until the user hits Control-C
  while (TRUE)
  { 
    //** this tells the Server the max number of MAP events that can be returned to us in one read
    NumMAPEvents = MAX_MAP_EVENTS_PER_READ;

    //** call the Server to get all the MAP events since the last time we called PL_GetTimeStampStructures
	  PL_GetTimeStampStructures(&NumMAPEvents, pServerEventBuffer);

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

    //** write the total number of timestamps to the console
    printf("%d data blocks (%d spike timestamps)\r\n", NumMAPEvents, NumSpikeTimestamps);

    //** yield to other programs for 200 msec before calling the Server again
    Sleep(200);
  }

  //** in this sample, we will never get to this point, but this is how we would free the 
  //** allocated memory and disconnect from the Server

  free(pServerEventBuffer);
  PL_CloseClient();

	return 0;
}

