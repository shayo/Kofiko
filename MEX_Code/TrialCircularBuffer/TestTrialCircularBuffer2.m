addpath('..\..\MEX\win32');
addpath('D:\Code\Doris\PublicLib\PTB\PsychBasic\MatlabWindowsFilesR2007a');

ALIGN_TO= 0;
TRIAL_START = 33000;
TRIAL_END = 33001;
TRIAL_TYPE = 10;
TRIAL_OUTCOME1 = 33002;
TRIAL_OUTCOME2 = 33003;

aiTrialOutcomes = [TRIAL_OUTCOME1, TRIAL_OUTCOME2];
aiKeepTrials = TRIAL_OUTCOME1;


NumChannels = 12;
NumUnitsPerChannel = 4;
LFP_Sampled_Freq = 2000;
LFP_Stored_Freq = 400; % Must be a multiple of LFP_Sampled_Freq ?
NumTrials = 200;
TrialLengthSec = 3;
Pre_TimeSec = 0.5;
Post_TimeSec = 0.5;

TrialCircularBuffer('Allocate',NumChannels,NumUnitsPerChannel,LFP_Sampled_Freq,LFP_Stored_Freq,NumTrials,TrialLengthSec,Pre_TimeSec,Post_TimeSec);

NumConditions = 3;
NumTrialTypes = 2;
a2bTrialTypeToCondition = ones(NumTrialTypes,NumConditions)>0;
a2bTrialTypeToCondition(:,2) = [1 0];
a2bTrialTypeToCondition(:,3) = [0 1];


strctOpt = TrialCircularBuffer('GetOpt');
strctOpt.TrialStartCode = TRIAL_START;
strctOpt.TrialEndCode = TRIAL_END;
strctOpt.TrialAlignCode = ALIGN_TO;
strctOpt.TrialOutcomesCodes = aiTrialOutcomes;
strctOpt.KeepTrialOutcomeCodes = aiKeepTrials;
strctOpt.TrialTypeToConditionMatrix = a2bTrialTypeToCondition;
strctOpt.ConditionOutcomeFilter = cell(1, NumConditions); %  no outcome filtering
strctOpt.ConditionOutcomeFilter{2} = [TRIAL_OUTCOME2];
strctOpt.ConditionOutcomeFilter{3} = [TRIAL_OUTCOME1,TRIAL_OUTCOME2];
strctOpt.PSTH_BinSizeMS = 10;
strctOpt.LFP_ResolutionMS = 5;

TrialCircularBuffer('SetOpt',strctOpt); 
strctOpt = TrialCircularBuffer('GetOpt');
strctOpt

%TrialCircularBuffer('Allocate',NumChannels,NumUnitsPerChannel,LFP_Sampled_Freq,LFP_Stored_Freq,NumTrials,TrialLengthSec,Pre_TimeSec,Post_TimeSec);
%TrialCircularBuffer('SetOpt',strctOpt); 


dbg = 1;


FiringRate = 50;
NumSeconds = 10;
Count = 1;
toffset = 0;

NumTrialsToSimulate = 500;
for TrialIter=1:NumTrialsToSimulate
    fprintf('Simulating Trial %d \n',TrialIter);
    if mod(TrialIter,2) == 0
        TrialType = 1;
    else
        TrialType = 2;
    end
    
    A0=GetSecs();
    [n,a2fSpikes]=fnGenerateRandomSpikes(...
        NumChannels, NumUnitsPerChannel, FiringRate, NumSeconds,toffset);
    
    % Embeed a trial
    index_start = find(a2fSpikes(:,4) >= toffset+Pre_TimeSec,1,'first');
    index_end = find(a2fSpikes(:,4) < toffset+Pre_TimeSec+TrialLengthSec,1,'last');
    a2fSpikeAndEvents = a2fSpikes;
    a2fSpikeAndEvents(index_start,1:3) = [4,0,TRIAL_START];
    a2fSpikeAndEvents(index_start+1,1:3) = [4,0,TrialType];
    a2fSpikeAndEvents(index_end-1,1:3) = [4,0,TRIAL_OUTCOME1];
    a2fSpikeAndEvents(index_end,1:3) = [4,0,TRIAL_END];
    
    fTrialStartTS = a2fSpikeAndEvents(index_start,4);
    % Fake a sine wave LFP of length 3.5 seconds
    fTotal = Pre_TimeSec+Pre_TimeSec+TrialLengthSec;
    NumSamples = ceil(fTotal * LFP_Sampled_Freq);
    fFreq = TrialType;
    afLFP= sin(2*pi*fFreq*linspace(0,2*pi,NumSamples));
    afTime = linspace(-Pre_TimeSec,Pre_TimeSec+TrialLengthSec,NumSamples);
    %figure(1);clf;plot(afTime,afLFP);
    AD = repmat(afLFP(:), 1, NumChannels);
    
    AD_Time = repmat(fTrialStartTS-Pre_TimeSec,1, NumChannels);
    % Update A/D
    A1=GetSecs();
    TrialCircularBuffer('UpdatePlexon', [], AD(:,1:NumChannels), AD_Time);
    A2=GetSecs();
    % Update Trial
    TrialCircularBuffer('UpdatePlexon', a2fSpikeAndEvents, [], []);
    A3=GetSecs();
    toffset = a2fSpikeAndEvents(end,4);
    
    %TrialStruct = TrialCircularBuffer('GetTrial', TrialIter-1);

    A4=GetSecs();
    [a4fPSTH, a3fLFP,afLFP_Time, afSpike_Time]=...
        TrialCircularBuffer('GetAllPSTH');
    A5=GetSecs();

    fprintf('Trial Update time = %.2f ms, PSTH query = %.2f ms \n', (A3-A1)*1e3, (A5-A4)*1e3);
    
        dbg = 1;
end

DotRasters = TrialCircularBuffer('GetRastersForPlot', 1);

	
for Ch=1:size(a3fLFP,3)
    for Con=1:size(a3fLFP,2)
        A=squeeze(a3fLFP(:,Con,Ch));
        figure(Ch);
        subplot(size(a3fLFP,2),1,Con);
        plot(afLFP_Time,A);
    end
end
   


for Ch=1:NumChannels
    for Unit=1:NumUnitsPerChannel
        
        for Con=1:NumConditions
            A=squeeze(a4fPSTH(:,Con,Unit,Ch));
            figure(Ch);
            subplot(NumUnitsPerChannel, NumConditions,Con + (Unit-1)*NumConditions);
            plot(afSpike_Time,A * 1/(strctOpt.PSTH_BinSizeMS/1e3)  );
            title(sprintf('Unit %d Cond %d',Unit,Con));
        end
    end
end
        


return;

aiWarningCounter = TrialCircularBuffer('GetWarningCounters');


[a4fPSTH, a3fLFP]=...
            TrialCircularBuffer('GetAllPSTH');

figure;plot(squeeze(a3fLFP(1,3,:)))
SpikeBuf = TrialCircularBuffer('GetSpikeBuffer');
abNotNaN=~isnan(SpikeBuf(:,1));


% 
% for k=0:9
% TrialStruct = TrialCircularBuffer('GetTrial', k);
% figure(k+1);
% plot(TrialStruct.LFP);
% end

N = 100;
afTimeLoop = zeros(1,N);
afTimeNoLoop = zeros(1,N);
for k=1:N
A3=GetSecs();
for Ch=1:NumChannels
    for Unit=1:NumUnitsPerChannel
        A2=GetSecs();
        [afBinTimesSec, a2fPSTH, aiNumValidTrails,a2fLFP]=...
            TrialCircularBuffer('GetPSTH', Ch,Unit, a2bTrialTypeToCondition,Outcomes,  fBinSizeMS, PreAlignSec, PostAlignSec);
        B2=GetSecs();
    end
end
B3=GetSecs();
afTimeLoop(k)=(B3-A3)*1e3;

A4=GetSecs();
[afBinTimesSec, a4fPSTH, aiNumValidTrails,a3fLFP]=...
            TrialCircularBuffer('GetAllPSTH', a2bTrialTypeToCondition,Outcomes,  fBinSizeMS, PreAlignSec, PostAlignSec);
B4 = GetSecs();
afTimeNoLoop(k) = (B4-B3)*1e3;

end



% figure;
% for k=1:NumConditions
%     subplot(NumConditions,1,k);
% 	plot(afBinTimesSec,a2fLFP(k,:),'LineWidth',2);
% end
% figure;
% for k=1:NumConditions
%     subplot(NumConditions,1,k);
%     bar(afBinTimesSec,fBinSizeMS*a2fPSTH(k,:),'LineStyle','none');
% end
% 

TrialCircularBuffer('Release');


     