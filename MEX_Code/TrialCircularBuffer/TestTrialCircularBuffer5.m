addpath('..\..\MEX\win32');
addpath('D:\Code\Doris\PublicLib\PTB\PsychBasic\MatlabWindowsFilesR2007a');

X=TrialCircularBuffer('InitPlexon');

X=TrialCircularBuffer('GetChannelNames');
X=TrialCircularBuffer('GetTimeStampTick');


load('..\..\DebugTrialStat');
% load('DebugTrialStat2');

TrialCircularBuffer('Allocate',Opt.NumChannels,Opt.NumUnitsPerChannel,Opt.LFP_Sampled_Freq,Opt.LFP_Stored_Freq,Opt.NumTrials,Opt.TrialLengthSec,Opt.Pre_TimeSec,Opt.Post_TimeSec);
TrialCircularBuffer('SetOpt',Opt); 

 TrialCircularBuffer('UpdatePlexon', a2fSpikeAndEvents, a2fLFP(:,[8 8]), afAnalogTime);
 
TrialCircularBuffer('Release');


     