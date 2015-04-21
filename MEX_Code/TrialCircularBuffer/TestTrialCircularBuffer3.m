addpath('..\..\MEX\win32');
addpath('D:\Code\Doris\PublicLib\PTB\PsychBasic\MatlabWindowsFilesR2007a');

fprintf('Loading...');
load('..\..\DebugTrialStatLong.mat');
fprintf('Done!\n');
% load('DebugTrialStat2');

fprintf('Allocating...');
TrialCircularBuffer('Allocate',Opt.NumChannels,Opt.NumUnitsPerChannel,Opt.LFP_Sampled_Freq,Opt.LFP_Stored_Freq,Opt.NumTrials,Opt.TrialLengthSec,Opt.Pre_TimeSec,Opt.Post_TimeSec,40);
TrialCircularBuffer('SetOpt',Opt); 

fprintf('Done!\n');

%a2fSpikeAndEvents=cat(1,g_DebugDataLog{:,1});
% fprintf('%d Experiments are in the buffer... \n',sum(a2fSpikeAndEvents(:,3) == Opt.TrialStartCode));

fprintf('Updating...\n');

iNumUpdates = size(g_DebugDataLog,1);
for UpdateIter=1:iNumUpdates
    a2fSpikeAndEvents = g_DebugDataLog{UpdateIter,1};
    a2fLFP = g_DebugDataLog{UpdateIter,2};
    afAnalogTime = g_DebugDataLog{UpdateIter,3};
    WaveForms = g_DebugDataLog{UpdateIter,4};
    TrialCircularBuffer('UpdatePlexon', a2fSpikeAndEvents, a2fLFP, afAnalogTime,WaveForms);
%     WaitSecs(0.0001);
%     [a4fPSTH, a3fLFP,afLFP_Time, afSpike_Time] = TrialCircularBuffer('GetAllPSTH');
end
fprintf('Done!\n');
fprintf('Releasing...\n');


TrialCircularBuffer('Release');

fprintf('Done!\n');

     