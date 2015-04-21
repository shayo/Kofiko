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
% Generate trials

% iNumTrials = 20;
% timecounter = 1000;
% for k=1:iNumTrials
%     % Generate random spikes
%     aiRandomChannel = zeros(1,
%     % Generate Start trial
%     
%     % Generate random spikes
%     
%     % Generate end trial
%     
%     % Generate random spikes
% end

t = [1, 3, 2, 1000;
     1, 1, 4, 1001;
     1, 2, 4, 1001.6;
     1, 2, 4, 1001.7;
     1, 2, 4, 1001.9;
     4, 0, TRIAL_START, 1002;
     1, 2, 4, 1002.2;
     4, 0, TRIAL_TYPE, 1002.21;
     1, 2, 4, 1002.3;
     1, 2, 4, 1002.7;     
     4, 2, 4, 1003; % Indicate trial type
     4, 0, TRIAL_OUTCOME1, 1003.9;
     4, 0, TRIAL_END, 1004;
     1, 2, 4, 1004.6;
     1, 2, 4, 1004.7;
     1, 2, 4, 1004.8;
     4, 0, TRIAL_START, 1005;
     4, 0, TRIAL_TYPE, 1005.1;
     1, 2, 4, 1005.2;
     1, 2, 3, 1005.25;
     1, 2, 4, 1005.3;
     1, 2, 4, 1006.7;     
     4, 2, 4, 1007; % Indicate trial type
     4, 0, TRIAL_OUTCOME2, 1007.05
     4, 0, TRIAL_END, 1007.1;     
     1, 2, 4, 1008.7;     
     4, 2, 4, 1009; % Indicate trial type
     ];
 



NumChannels = 12;
NumUnitsPerChannel = 4;
LFP_Freq = 2000;
NumTrials = 1000;
TrialLengthSec = 3;
Pre_TimeSec = 0.5;
Post_TimeSec = 0.5;

TrialCircularBuffer('Allocate',NumChannels,NumUnitsPerChannel,LFP_Freq,NumTrials,TrialLengthSec,Pre_TimeSec,Post_TimeSec);

TrialCircularBuffer('SetOpt',ALIGN_TO, TRIAL_START, TRIAL_END, aiTrialOutcomes, aiKeepTrials);

AD = [];
AD_Time = [];
A1=GetSecs();
TrialCircularBuffer('UpdatePlexon', t, AD, AD_Time);
B1=GetSecs();

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

figure;plot(afBinTimesSec, a2fPSTH(1,:))
TrialCircularBuffer('Release');


     
TrialCircularBuffer('InitPlexon');
X=TrialCircularBuffer('GetChannelNames');
