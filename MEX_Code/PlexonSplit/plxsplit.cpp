#include <stdio.h>
#include "mex.h"
#include <string>
#include <math.h>
#include "Plexon.h"



#define MAX(a,b)( (a)<(b)?(b):(a))
#define MIN(a,b)( (a)<(b)?(a):(b))

void printheaderinfo(PL_FileHeader& fh);


/* Entry Points */
void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{
	static char buff[900+1];
	buff[0]=0;
	mxGetString(prhs[0],buff,900);


	FILE* fp = fopen(buff, "rb");
	if(fp == 0){
		printf("Cannot open %s",buff);
		exit(1);
	}
	PL_FileHeader fh;
	// first, read file header
	fread(&fh, sizeof(fh), 1, fp);

	// print file header information
	printheaderinfo(fh);

	// read channel headers
	PL_ChanHeader channels[128];
	PL_EventHeader evheaders[512];
	PL_SlowChannelHeader slowheaders[64];

	memset(channels, 0, 128*sizeof(PL_ChanHeader));
	memset(evheaders, 0, 512*sizeof(PL_EventHeader));
	memset(slowheaders, 0, 64*sizeof(PL_SlowChannelHeader));

	if(fh.NumDSPChannels > 0)
		fread(channels, fh.NumDSPChannels*sizeof(PL_ChanHeader), 1, fp);
	if(fh.NumEventChannels> 0)
		fread(evheaders, fh.NumEventChannels*sizeof(PL_EventHeader), 1, fp);
	if(fh.NumSlowChannels)
		fread(slowheaders, fh.NumSlowChannels*sizeof(PL_SlowChannelHeader), 1, fp);
	
	PL_DataBlockHeader db;
	short buf[256];
	// where the data starts
	int datastart = sizeof(fh) + fh.NumDSPChannels*sizeof(PL_ChanHeader)
						+ fh.NumEventChannels*sizeof(PL_EventHeader)
						+ fh.NumSlowChannels*sizeof(PL_SlowChannelHeader);

	int nbuf;

	// SAMPLE 1:
	// read the timestamps for a spike channel
	//

	int channel_to_extract = 1; // dsp channel numbers are 1-based
	int unit_to_extract = 1;
	int count = 1;
	printf("\nTimestamps for channel %d, unit %d\n", 
		channel_to_extract, unit_to_extract);

	while(feof(fp) == 0 && fread(&db, sizeof(db), 1, fp) == 1){ // read the block
		nbuf = 0;
		if(db.NumberOfWaveforms > 0){ // read the waveform after the block
			nbuf = db.NumberOfWaveforms*db.NumberOfWordsInWaveform;
			fread(buf, nbuf*2, 1, fp);
		}
		if(db.Type == PL_SingleWFType){ // both timestamps and waveforms have this type
			if(db.Channel == channel_to_extract && db.Unit == unit_to_extract){ 
				printf("spike: %d ticks: %d seconds: %.6f\n", count, db.TimeStamp,
						db.TimeStamp/(double)fh.ADFrequency);
				count++;
			}
		}
	}

	// SAMPLE 2:
	//  read the waveforms for a spike channel
	//

	channel_to_extract = 1;
	unit_to_extract = 1;
	count = 1;
	printf("\nWaveforms for channel %d, unit %d\n", 
		channel_to_extract, unit_to_extract);

	// rewind file to the data start!!!
	fseek(fp, datastart, SEEK_SET);
	int i;
	while(feof(fp) == 0 && fread(&db, sizeof(db), 1, fp) == 1){ // read the block
		nbuf = 0;
		if(db.NumberOfWaveforms > 0){ // read the waveform after the block
			nbuf = db.NumberOfWaveforms*db.NumberOfWordsInWaveform;
			fread(buf, nbuf*2, 1, fp);
		}
		if(db.Type == PL_SingleWFType && nbuf > 0){ 
			if(db.Channel == channel_to_extract && db.Unit == unit_to_extract){ 
				printf("spike: %d ticks: %d seconds: %.6f\n", count, db.TimeStamp,
						db.TimeStamp/(double)fh.ADFrequency);
				printf("waveform:");
				for(i=0; i<db.NumberOfWordsInWaveform; i++){
					printf(" %d,", buf[i]);
				}
				printf("\n");
				count++;
			}
		}
	}

	
	// SAMPLE 3
	//   read the timestamps for an external event channel
	//
	int event_to_extract = 1;
	count = 1;
	printf("\nTimestamps for event %d\n", 
		event_to_extract);
	
	// rewind file to the data start!!!
	fseek(fp, datastart, SEEK_SET);

	while(feof(fp) == 0 && fread(&db, sizeof(db), 1, fp) == 1){ // read the block
		nbuf = 0;
		if(db.NumberOfWaveforms > 0){ // read the waveform after the block
			nbuf = db.NumberOfWaveforms*db.NumberOfWordsInWaveform;
			fread(buf, nbuf*2, 1, fp);
		}
		if(db.Type == PL_ExtEventType){ 
			if(db.Channel == event_to_extract){ 
				printf("event: %d ticks: %d seconds: %.6f\n", count, db.TimeStamp,
					db.TimeStamp/(double)fh.ADFrequency);
				count++;
			}
		}
	}

	// SAMPLE 4
	//  read continuous data for one channel
	//   please note that a/d data does not start
	//      at time 0!!!
	//   the timestamps for the a/d data points need to be
	//      calculated
	//    converting to voltage: 5V corresponds to the a/d value of 2048 

	channel_to_extract = 0; // a/d channel numbers are zero-based!!!
	count = 1;
	printf("\nContinuous data for channel %d\n", 
		channel_to_extract);
	
	// rewind file to the data start!!!
	fseek(fp, datastart, SEEK_SET);

	// find the header for this a/d channel
	int header_num = -1;
	for(i=0; i<fh.NumSlowChannels; i++){
		if(slowheaders[i].Channel == channel_to_extract){
			header_num = i;
			break;
		}
	}
	if(header_num == -1){
		printf("No header for the specified A/D channel!\n");
		fclose(fp);
		exit(1);
	}

	int gain = slowheaders[header_num].Gain;
	int adfreq = slowheaders[header_num].ADFreq;

	if(adfreq == 0 || gain == 0){
		printf("No A/D frequency or gain!\n");
		fclose(fp);
		exit(1);
	}
	int ticks_in_adcycle = fh.ADFrequency/adfreq;

	int first_timestamp = -1;
	int ts;
	while(feof(fp) == 0 && fread(&db, sizeof(db), 1, fp) == 1){ // read the block
		nbuf = 0;
		if(db.NumberOfWaveforms > 0){ // read the waveform after the block
			nbuf = db.NumberOfWaveforms*db.NumberOfWordsInWaveform;
			fread(buf, nbuf*2, 1, fp);
		}
		if(db.Type == PL_ADDataType){ 
			if(db.Channel == channel_to_extract){
				if(first_timestamp == -1){
					printf("first data point at: %d ticks: %d seconds: %.6f\n", count, db.TimeStamp,
						db.TimeStamp/(double)fh.ADFrequency);
				first_timestamp = db.TimeStamp;
				}
				for(i=0; i<db.NumberOfWordsInWaveform; i++){
					ts = db.TimeStamp + i*ticks_in_adcycle;
					// voltage: 5V corresponds to the a/d value of 2048 
					double v = (buf[i]*5./2048.)/(double)gain;

					printf("a/d value %5d (%6.3f V) at %d ticks or %.6f seconds\n", 
						buf[i], v, ts, ts/(double)fh.ADFrequency);
				}
				count++;
			}
		}
	}

	fclose(fp);
}

void printheaderinfo(PL_FileHeader& fh)
{
	printf("File Version: %d\n", fh.Version);
	printf("File Comment: %s\n", fh.Comment);
	printf("Frequency: %d\n", fh.ADFrequency);
	printf("DSP Channels: %d\n", fh.NumDSPChannels);
	printf("Event Channels: %d\n", fh.NumEventChannels);
	printf("A/D Channels: %d\n", fh.NumSlowChannels);
	int i, j;
	printf("\nTimestamps:\n");
	for(i=0; i<130; i++){
		for(j=0; j<5; j++){
			if(fh.TSCounts[i][j] > 0){
				printf("Channel %03d Unit %d Count %d\n", i, j, fh.TSCounts[i][j]);
			}
		}
	}
	printf("\nWaveforms:\n");
	for(i=0; i<130; i++){
		for(j=0; j<5; j++){
			if(fh.WFCounts[i][j] > 0){
				printf("Channel %03d Unit %d Count %d\n", i, j, fh.TSCounts[i][j]);
			}
		}
	}
	printf("\nEvents:\n");
	for(i=0; i<299; i++){
		if(fh.EVCounts[i] > 0){
			printf("Event %03d Count %d\n", i, fh.EVCounts[i]);
		}
	}
	printf("\nA/D channels:\n");
	for(i=300; i<512; i++){
		if(fh.EVCounts[i] > 0){
			printf("channel %02d data points %d\n", i-300+1, fh.EVCounts[i]);
		}
	}
}

