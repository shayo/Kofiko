s=PL_InitClient(0);

%addpath('..\..\MEX\win32');
addpath('.\MEX\win32');

ALIGN_TO= 0;
TRIAL_START = 33000;
TRIAL_END = 33001;
TRIAL_TYPE = 10;
TRIAL_OUTCOME1 = 33002;
TRIAL_OUTCOME2 = 33003;

aiTrialOutcomes = [TRIAL_OUTCOME1, TRIAL_OUTCOME2];
aiKeepTrials = TRIAL_OUTCOME1;


NumChannels = 2;
NumUnitsPerChannel = 4;
LFP_Sampled_Freq = 2000;
LFP_Stored_Freq = 2000; % Must be a multiple of LFP_Sampled_Freq ?
NumTrials = 1000;
TrialLengthSec = 3;
Pre_TimeSec = 0.5;
Post_TimeSec = 0.5;

TrialCircularBuffer('Allocate',NumChannels,NumUnitsPerChannel,LFP_Freq,LFP_Stored_Freq,NumTrials,TrialLengthSec,Pre_TimeSec,Post_TimeSec);

TrialCircularBuffer('SetOpt',ALIGN_TO, TRIAL_START, TRIAL_END, aiTrialOutcomes, aiKeepTrials);

for k=1:100
A0=GetSecs();
[n, a2fSpikeAndEvents] =PL_GetTS(s);
[n1, AD_Time, AD] = PL_GetADVEx(s);
A1=GetSecs();
TrialCircularBuffer('UpdatePlexon', a2fSpikeAndEvents, AD(:,1:NumChannels), AD_Time);
B1=GetSecs();
fprintf('%d spike and strobe entries, %d AD, query time = %.2f ms, update time: %.2f ms, total cycle : %.2f ms \n', n,n1(1), (A1-A0)*1e3, (B1-A1)*1e3,(B1-A0)*1e3);
WaitSecs(0.5);
end


A=TrialCircularBuffer('GetRasterCell', 2,3,0);

B=TrialCircularBuffer('GetRaster', 2,4,0);

fBinSizeMS = 20;
a2bTrialTypeToCondition = ones(30,3)>0;

PreAlignSec = Pre_TimeSec;
PostAlignSec = Post_TimeSec;
Outcomes = [];

A2=GetSecs();
[afBinTimesSec, a2fPSTH, aiNumValidTrails]=TrialCircularBuffer('GetPSTH', 2,4, a2bTrialTypeToCondition,Outcomes,  fBinSizeMS, PreAlignSec, PostAlignSec);
B2=GetSecs();

TrialCircularBuffer('Release');


     