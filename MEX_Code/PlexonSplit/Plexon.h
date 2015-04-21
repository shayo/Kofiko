// digitizer file header
struct DigFileHeader {
	int		Version;
	int		DataOffset;
	double	Freq;
	int		NChannels;
	int		Year; // when the file is created
	int		Month; // when the file is created
	int		Day; // when the file is created
	int		Hour; // when the file is created
	int		Minute; // when the file is created
	int		Second; // when the file is created
	int		Gain; 
	char	Comment[128];
	int		Padding[64]; 
};


// plexon.h: objects that are exposed to clients
//

struct PL_ServerArea{
	int	Version; // MMF version 100
	int ParAreaSize;  // 512
	int TSTick; // in microsec., multiple of 25
	int WFLength;  // 128
	int NumWF;   // number of waveforms in the MMF,
				// set in the server options
	int StartWFBuffer; // equals to the length of this structure
	int MMFLength;   //total length of the MMF
					// = StartWFBuffer + WFLength*NumWF
	// current nums for waveforms and timestamps
	int WFNum;		// absolute number of waveforms written to the MMF
	int TSNum;
	int NumDropped; // number of w/f dropped by the server
	int NumSpikeChannels; 
	int NumEventChannels;
	int NumContinuousChannels;
	};

#define	PL_SingleWFType			(1)
#define	PL_ExtEventType			(4)
#define	PL_ADDataType			(5)
#define	PL_StrobedExtChannel	(257)
#define	PL_StartExtChannel		(258)
#define	PL_StopExtChannel		(259)

// MMF has a circular buffer of PL_Wave structures.
// this structure is used in MMF as the first part of the
// PL_Wave structure -- see PL_Wave below.
//
// PL_Event is used in PL_GetTimestampStructures(...)

struct PL_Event{
	char	Type;  // so far, PL_SingleWFType or PL_ExtEventType
	char	NumberOfBlocksInRecord;
	char	BlockNumberInRecord;
	char	UpperTS; // fifth byte of the waveform
	long	TimeStamp;
	short	Channel;
	short	Unit;
	char	DataType; // tetrode stuff, ignore for now
	char	NumberOfBlocksPerWaveform; // tetrode stuff, ignore for now
	char	BlockNumberForWaveform; // tetrode stuff, ignore for now
	char	NumberOfDataWords; // number of shorts (2-byte integers) that follow this header 
	}; // 16 bytes

#define		MAX_WF_LENGTH	(56)
#define		MAX_WF_LENGTH_LONG	(120)

// the same as event above with extra waveform
// this is the structure used in the MMF
struct PL_Wave {
	char	Type;
	char	NumberOfBlocksInRecord;
	char	BlockNumberInRecord;
	char	UpperTS;
	long	TimeStamp;
	short	Channel;
	short	Unit;
	char	DataType; // tetrode stuff, ignore for now
	char	NumberOfBlocksPerWaveform; // tetrode stuff, ignore for now
	char	BlockNumberForWaveform; // tetrode stuff, ignore for now
	char	NumberOfDataWords; // number of shorts (2-byte integers) that follow this header 
	short	WaveForm[MAX_WF_LENGTH];
}; // size should be 128

struct PL_WaveLong {
	char	Type;
	char	NumberOfBlocksInRecord;
	char	BlockNumberInRecord;
	char	UpperTS;
	long	TimeStamp;
	short	Channel;
	short	Unit;
	char	DataType; // tetrode stuff, ignore for now
	char	NumberOfBlocksPerWaveform; // tetrode stuff, ignore for now
	char	BlockNumberForWaveform; // tetrode stuff, ignore for now
	char	NumberOfDataWords; // number of shorts (2-byte integers) that follow this header 
	short	WaveForm[MAX_WF_LENGTH_LONG];
}; // size should be 256


// .plx file structure
// file header (is followed by the channel descriptors)
struct	PL_FileHeader {
	unsigned int	MagicNumber; //	= 0x58454c50;
	int		Version;
	char    Comment[128];
	int		ADFrequency; // Timestamp frequency in hertz
	int		NumDSPChannels; // Number of DSP channel headers in the file
	int		NumEventChannels; // Number of Event channel headers in the file
	int		NumSlowChannels; // Number of A/D channel headers in the file
	int		NumPointsWave; // Number of data points in waveform
	int		NumPointsPreThr; // Number of data points before crossing the threshold
	int		Year; // when the file was created
	int		Month; // when the file was created
	int		Day; // when the file was created
	int		Hour; // when the file was created
	int		Minute; // when the file was created
	int		Second; // when the file was created
	int		FastRead; // not used
	int		WaveformFreq; // waveform sampling rate; ADFrequency above is timestamp freq 
	double	LastTimestamp; // duration of the experimental session, in ticks
	char	Padding[56]; // so that this part of the header is 256 bytes
	// counters
	int		TSCounts[130][5]; // number of timestamps[channel][unit]
	int		WFCounts[130][5]; // number of waveforms[channel][unit]
	int		EVCounts[512];    // number of timestamps[event_number]
};


struct PL_ChanHeader {
	char	Name[32];
	char	SIGName[32];
	int		Channel;// DSP channel, 1-based
	int		WFRate;	// w/f per sec divided by 10
	int		SIG;    // 1 - based
	int		Ref;	// ref sig, 1- based
	int		Gain;	// 1-32, actual gain divided by 1000
	int		Filter;	// 0 or 1
	int		Threshold;	// +- 2048, a/d values
	int		Method; // 1 - boxes, 2 - templates
	int		NUnits; // number of sorted units
	short	Template[5][64]; // a/d values
	int		Fit[5];			// template fit 
	int		SortWidth;		// how many points to sort (template only)
	short	Boxes[5][2][4];
	int		Padding[44];
};

struct PL_EventHeader {
	char	Name[32];
	int		Channel;// input channel, 1-based
	int		IsFrameEvent; // frame start/stop signal
	int		Padding[64];
};

struct PL_SlowChannelHeader {
	char	Name[32];
	int		Channel;// input channel, 0-based
	int		ADFreq; 
	int		Gain;
	int		Enabled;
	int		Padding[62];
};

// the record header used in the datafile (*.plx)
// it is followed by NumberOfWaveforms*NumberOfWordsInWaveform
// short integers that represent the waveform(s)
struct PL_DataBlockHeader{
	short	Type;
	short	UpperByteOf5ByteTimestamp;
	long	TimeStamp;
	short	Channel;
	short	Unit;
	short	NumberOfWaveforms;
	short	NumberOfWordsInWaveform; 
}; // 16 bytes


// extracted file header
struct ShortHeader {
	char	FileName[512];
	int		Version;
	int		Channel;
	int		NWaves;
	int		NPointsWave;
	int		TSFrequency;
	int		WaveFormFreq;
	int		ValidPCA;
	float	PCA[8][128];
	int		Padding[256];
};


// global parameter area (a separate MMF)
// we will use the plx file channel info:
struct PL_ServerPars {
	int			NumDSPChannels; 
	int			NumSIGChannels;
	int			NumOUTChannels;
	int			NumEventChannels;
	int			NumContinuousChannels;
	int			TSTick; // in microsec., multiple of 25
	int			NumPointsWave; 
	int			NumPointsPreThr; 
	int			GainMultiplier; 
	int			SortClientRunning;
	int			ElClientRunning;
	int			NIDAQEnabled;
	int			SlowFrequency;
	int			DSPProgramLoaded;
	int			PollTimeHigh;
	int			PollTimeLow;
	int			MaxWordsInWF;
	int			ActiveChannel;
	int			Out1Info;
	int			Out2Info;
	int			SWH;
	int			PollingInterval;
	int			Padding[56];
	// not all the info will be stored
	// for example, no names to start with
	PL_ChanHeader Channels[128]; 
	PL_EventHeader Events[512]; 
	PL_SlowChannelHeader SlowChannels[32];
};

// increased number of slow channels to 64
struct PL_ServerPars1 {
	int			NumDSPChannels; 
	int			NumSIGChannels;
	int			NumOUTChannels;
	int			NumEventChannels;
	int			NumContinuousChannels;
	int			TSTick; // in microsec., multiple of 25
	int			NumPointsWave; 
	int			NumPointsPreThr; 
	int			GainMultiplier; 
	int			SortClientRunning;
	int			ElClientRunning;
	int			NIDAQEnabled;
	int			SlowFrequency;
	int			DSPProgramLoaded;
	int			PollTimeHigh;
	int			PollTimeLow;
	int			MaxWordsInWF;
	int			ActiveChannel;
	int			Out1Info;
	int			Out2Info;
	int			SWH;
	int			PollingInterval;
	int			NIDAQ_NCh;
	int			Padding[55];
	// not all the info will be stored
	// for example, no names to start with
	PL_ChanHeader Channels[128]; 
	PL_EventHeader Events[512]; 
	PL_SlowChannelHeader SlowChannels[64];
};


#define COMMAND_LENGTH	(260)

#define WM_CONNECTION_CLOSED	(WM_USER + 401)

#if 0

extern "C" int		WINAPI PL_InitClient(int type, HWND hWndList);
// if the server closes connection, dll sends WM_CONNECTION_CLOSED message
// to hWndMain
extern "C" int		WINAPI PL_InitClientEx2(int type, HWND hWndMain);
extern "C" int		WINAPI PL_InitClientEx3(int type, HWND hWndList, HWND hWndMain);
extern "C" void		WINAPI PL_CloseClient();

// server control commands
extern "C" void		WINAPI PL_StartDataPump();
extern "C" void		WINAPI PL_InitDataTransfer();
extern "C" void		WINAPI PL_RestartDataAcq();
extern "C" void		WINAPI PL_StopDataPump();
extern "C" int		WINAPI PL_SendCommand(int com);
extern "C" int		WINAPI PL_SendCommandBuffer(UCHAR* buf);
extern "C" void		WINAPI PL_SendUserEvent(int channel);

// reads from the main MMF
extern "C" int      WINAPI PL_IsLongWaveMode();

extern "C" void		WINAPI PL_GetTimeStampArrays(int* pnmax, short* type, short* ch,
											  short* cl, int* ts);
extern "C" void		WINAPI PL_GetTimeStampStructures(int* pnmax, 
														PL_Event* events);
extern "C" void     WINAPI PL_GetTimeStampStructuresEx(int* pnmax, 
													PL_Event* events,
													int* pollhigh,
													int* polllow);
extern "C" void		WINAPI PL_GetWaveFormStructures(int* pnmax, 
														PL_Wave* waves);
extern "C" void		WINAPI PL_GetWaveFormStructuresEx(int* pnmax, 
										PL_Wave* waves, 
										int* serverdropped,
										int* mmfdropped);
extern "C" void		WINAPI PL_GetLongWaveFormStructures(int* pnmax, 
										PL_WaveLong* waves, 
										int* serverdropped,
										int* mmfdropped);

extern "C" void WINAPI PL_GetWaveFormStructuresEx2(int* pnmax, PL_Wave* waves,
												  int* serverdropped, 
												  int* mmfdropped,
												  int* pollhigh,
												  int* polllow);
extern "C" void WINAPI PL_GetLongWaveFormStructuresEx2(int* pnmax, PL_WaveLong* waves,
												  int* serverdropped, 
												  int* mmfdropped,
												  int* pollhigh,
												  int* polllow);

// here threshold is in +- 100% range, channel is 1-based
extern "C" void		WINAPI PL_SetThreshold(int channel, double thr);
extern "C" void		WINAPI PL_SetNPointsWave(int np);
extern "C" void		WINAPI PL_SetNPrePointsWave(int np);
extern "C" void		WINAPI PL_SetSortMethod(int ch, int m);
extern "C" void		WINAPI PL_SetNumUnits(int ch, int num);
extern "C" void		WINAPI PL_SetBox(int ch, int unit, int box, RECT& rc);
extern "C" void		WINAPI PL_SetUnit(int unit, int ch);
extern "C" void		WINAPI PL_SelectDSPOUT(int ch);
extern "C" void		WINAPI PL_DeselectDSPOUT(int ch);
extern "C" void		WINAPI PL_LoadTemplate(int ch, int unit, int npw, short* templ);
extern "C" void		WINAPI PL_LoadTemplFit(int ch, int unit, int fit);
extern "C" void		WINAPI PL_SetPCA(int ch, int pc, int np, float* pca);
extern "C" void		WINAPI PL_SetValidPCA(int ch, int v);
extern "C" void		WINAPI PL_SetMinMax(int ch, float* fbuf);
extern "C" void		WINAPI PL_LoadConfiguration(const char* path);
extern "C" void		WINAPI PL_SaveConfiguration(const char* path);
extern "C" void		WINAPI PL_SetGain(int ch, int gain);
extern "C" void		WINAPI PL_SetGainGlobal(int gain);
extern "C" void		WINAPI PL_SetFilter(int ch, int f);
extern "C" void		WINAPI PL_SetFilterGlobal(int f);
extern "C" void		WINAPI PL_SetName(int ch, char* name);
extern "C" void		WINAPI PL_SetEventName(int ch, char* name);
extern "C" void		WINAPI PL_WFRateOn();
extern "C" void		WINAPI PL_WFRateOff();
extern "C" void		WINAPI PL_SetWFRateGlobal(int t);
extern "C" void		WINAPI PL_SetWFRate(int ch, int t);
extern "C" void		WINAPI PL_SetNPointsSort(int ch, int nps);
extern "C" void		WINAPI PL_XON(int chin, int chout);
extern "C" void		WINAPI PL_XOF(int chout);
extern "C" void		WINAPI PL_X64();
extern "C" void		WINAPI PL_OON(int chin, int chout);
extern "C" void		WINAPI PL_OOF(int chout);
extern "C" void		WINAPI PL_OOF_Ex(int board, int chout);
extern "C" void		WINAPI PL_SendSerialCommand(char* cmd);
extern "C" void		WINAPI PL_SetMode(int mode);
extern "C" void		WINAPI PL_StartRecording();
extern "C" void		WINAPI PL_StopRecording();
extern "C" void		WINAPI PL_SetSlowFreq(int freq);
extern "C" void		WINAPI PL_SetSlowChannels(int* channels);
extern "C" void		WINAPI PL_SetSlowChanGains(int* gains);
extern "C" void		WINAPI PL_SetSlowChannels64(int* channels);
extern "C" void		WINAPI PL_SetSlowChanGains64(int* gains);
extern "C" void		WINAPI PL_SetActiveChannel(int channel);

// "get" commands
extern "C" void		WINAPI PL_GetOUTInfo(int* out1, int* out2);
extern "C" void		WINAPI PL_GetSlowInfo(int* freq, int* channels, int* gains);
extern "C" void		WINAPI PL_GetSlowInfo64(int* freq, int* channels, int* gains);
extern "C" int		WINAPI PL_GetActiveChannel();
extern "C" int		WINAPI PL_IsElClientRunning();
extern "C" int		WINAPI PL_IsSortClientRunning();
extern "C" int		WINAPI PL_IsNIDAQEnabled();
extern "C" int		WINAPI PL_IsDSPProgramLoaded();
extern "C" int		WINAPI PL_GetTimeStampTick();
extern "C" void		WINAPI PL_GetGlobalPars(int* numch, int* npw, int* npre, int* gainmult);
extern "C" void		WINAPI PL_GetGlobalParsEx(int* numch, int* npw, int* npre, int* gainmult, int* maxwflength);
extern "C" void		WINAPI PL_GetChannelInfo(int* nsig, int* ndsp, int* nout);
extern "C" void		WINAPI PL_GetSIG(int* sig);
extern "C" void		WINAPI PL_GetFilter(int* filter);
extern "C" void		WINAPI PL_GetGain(int* gain);
extern "C" void		WINAPI PL_GetMethod(int* method);
extern "C" void		WINAPI PL_GetThreshold(int* thr);
extern "C" void		WINAPI PL_GetNumUnits(int* thr);
extern "C" void		WINAPI PL_GetTemplate(int ch, int unit, int* t);
extern "C" void		WINAPI PL_GetNPointsSort(int* t);
extern "C" int		WINAPI PL_SWHStatus();
extern "C" int		WINAPI PL_GetPollingInterval();
extern "C" int		WINAPI PL_GetNIDAQNumChannels();

// not implemented in the verison 09.98
extern "C" void		WINAPI PL_GetName(int ch, char* name);
extern "C" void		WINAPI PL_GetValidPCA(int* num);
extern "C" void		WINAPI PL_GetTemplateFit(int ch, int* fit);
extern "C" void		WINAPI PL_GetBoxes(int ch, int* b);
extern "C" void		WINAPI PL_GetPC(int ch, int unit, float* pc);
extern "C" void		WINAPI PL_GetMinMax(int ch,  float* mm);
extern "C" void		WINAPI PL_GetGlobalWFRate(int* t);
extern "C" void		WINAPI PL_GetWFRate(int* t);
extern "C" void		WINAPI PL_GetEventName(int ch, char* name);

#endif