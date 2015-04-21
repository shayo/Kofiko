function fnPipelineOptogeneticsMicrostim_v1(strctInputs)
clear global g_acDesignCache

strDataRootFolder = strctInputs.m_strDataRootFolder;
strConfigFolder   = strctInputs.m_strConfigFolder;
strSession        = strctInputs.m_strSession;

if strDataRootFolder(end) ~= filesep()
    strDataRootFolder(end+1) = filesep();
end;
fnWorkerLog('Starting invivo measurement pipeline...');
fnWorkerLog('Session : %s',strSession);
fnWorkerLog('Data Root : %s',strDataRootFolder);

strRawFolder = [strDataRootFolder,'RAW',filesep()];
strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);
strAdvancerFile = fullfile(strRawFolder,[strSession,'-Advancers.txt']);
strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);

aiInd = find(strSession=='_');
strSubject = strSession(aiInd(2)+1:end);
strTimeDate = strSession(1:aiInd(2)-1);

strTriggerFile =fullfile(strRawFolder,[strSession,'-Stimulation_Trig2.raw']); 
strTrainFile = fullfile(strRawFolder,[strSession,'-Grass_Train2.raw']);
 strExcitationFile = fullfile(strRawFolder,[strSession,'-NonAmplified_Photodiode.raw']); 
 strEmissionFile = fullfile(strRawFolder,[strSession,'-Amplified_Photodiode.raw']); 

strOutputFolder = [strDataRootFolder,'Processed',filesep(),'Fiberscope_Analysis',filesep()];
if ~exist(strOutputFolder,'dir')
    mkdir(strOutputFolder);
end;


%% Verify everything is around.

bAllExist = fnCheckForFilesExistence({strExcitationFile,strEmissionFile, strKofikoFile, strTriggerFile,strAdvancerFile, strStatServerFile,...
    strStrobeFile,strAnalogFile,strSyncFile});
if ~bAllExist
    fprintf('************ CRITICAL ERROR - FILE MISSING!\n');
    return;
end
% Load needed information to do processing
load(strSyncFile);
strctKofiko = load(strKofikoFile);
strctStatServer = load(strStatServerFile);

astrctChannelsGridInfo = fnGetChannelGridInfo(strctStatServer);




%%
afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;
%% Read advancer file for electrode position during the experiments...
a2fTemp = textread(strAdvancerFile);
afDepthRelativeToGridTop = a2fTemp(:,2);
aiAdvancerUniqueID = a2fTemp(:,1);
afAdvancerChangeTS_StatServer = a2fTemp(:,6);
afAdvancerChangeTS_Plexon = fnTimeZoneChange(afAdvancerChangeTS_StatServer,strctSync,'StatServer','Plexon');

strctAdvancersInformation.m_afDepthRelativeToGridTop = afDepthRelativeToGridTop;
strctAdvancersInformation.m_aiAdvancerUniqueID = aiAdvancerUniqueID;
strctAdvancersInformation.m_afAdvancerChangeTS_Plexon = afAdvancerChangeTS_Plexon;

%%


[strctTrigger, afTriggerTime] = fnReadDumpAnalogFile(strTrainFile);
[Dummy,astrctPulseIntervals] = fnIdentifyStimulationTrains(strctTrigger,afTriggerTime, false);
% Discard short pulses?
MinLength = 30000;
aiValid = find(cat(1,astrctPulseIntervals.m_iLength) > MinLength);
astrctPulseIntervals=astrctPulseIntervals(aiValid);
 if isempty(astrctPulseIntervals)
     fnWorkerLog('Failed to find any trigger information');
     return;
 end;
 
 % Load fluoresence resposne
[strctExc, afTime] = fnReadDumpAnalogFile(strExcitationFile);
[strctEmi, afTime] = fnReadDumpAnalogFile(strEmissionFile);
% Compute the response post stimulation.
fPreTime = 2000;
fPostTime = 10000+1000;
iNumBins = 1+fPreTime+fPostTime;
afRangeSec = (-fPreTime:fPostTime)/1e3;
iNumTrains = length(astrctPulseIntervals);
a2fSampleTimes = zeros(iNumTrains, iNumBins); % 1 ms resolution

for k=1:iNumTrains
    a2fSampleTimes(k,:) = afTime(astrctPulseIntervals(k).m_iStart) + afRangeSec;
end

a2fExc = reshape(interp1(afTime, strctExc.m_afData, a2fSampleTimes(:)), iNumTrains, iNumBins);
a2fEmi = reshape(interp1(afTime, strctEmi.m_afData, a2fSampleTimes(:)), iNumTrains, iNumBins);
aiValidTrains = find(median(a2fExc(:,find(afRangeSec > -800 &  afRangeSec < 0)),2) < 40);

afStableRange = find(afRangeSec > 8 & afRangeSec < 9);
afMeanExc = median(a2fExc(aiValidTrains,afStableRange),2);
afMeanEmi = median(a2fEmi(aiValidTrains,afStableRange),2);

 figure;
 plot(afRangeSec,a2fExc(aiValidTrains,:)')
 
 plot(afRangeSec,a2fEmi(aiValidTrains,:)')
 
 figure;clf;hold on;
 plot(afMeanExc,'b.');

 plot(afMeanEmi,'g.');
  
 
%%


 afTrainOnsets_TS_PLX = afTriggerTime( cat(1,astrctPulseIntervals(aiValidTrains).m_iStart));
 % How many channels do we have?
 iStimulatingChannel = 17;
 fMergeDistanceMM = 0.1;
 iAdvancerUniqueID = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(iStimulatingChannel,3);

 afSampleAdvancerTimes = afTrainOnsets_TS_PLX;
 afIntervalDepthMM= fnMyInterp1(strctAdvancersInformation.m_afAdvancerChangeTS_Plexon(strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID),...
        strctAdvancersInformation.m_afDepthRelativeToGridTop(strctAdvancersInformation.m_aiAdvancerUniqueID == iAdvancerUniqueID),afSampleAdvancerTimes);
 [afUniqueStimDepthMM, aiMappingToUnique, aiCount] = fnMyUnique(afIntervalDepthMM, fMergeDistanceMM);
 iNumUniqueDepthsStimulationGiven = length(afUniqueStimDepthMM);
 fnWorkerLog('Found %d unique depths at which stimulation was applied',iNumUniqueDepthsStimulationGiven);

%%
afMeanExcAtDpeth = zeros(1,iNumUniqueDepthsStimulationGiven);
afStdExcAtDpeth = zeros(1,iNumUniqueDepthsStimulationGiven);

afMeanEmiAtDpeth = zeros(1,iNumUniqueDepthsStimulationGiven);
afStdEmiAtDpeth = zeros(1,iNumUniqueDepthsStimulationGiven);

for k=1:iNumUniqueDepthsStimulationGiven
    aiInd = find(aiMappingToUnique == k);
    afMeanExcAtDpeth(k) = mean(afMeanExc(aiInd));
    afStdExcAtDpeth(k) = std(afMeanExc(aiInd));
    
    afMeanEmiAtDpeth(k) = mean(afMeanEmi(aiInd));
    afStdEmiAtDpeth(k) = std(afMeanEmi(aiInd));
end
[afSortedDepths, aiSortInd]=sort(afUniqueStimDepthMM);
figure(12);
clf;
plot(afSortedDepths,afMeanExcAtDpeth(:),'bd');
hold on;
plot(afSortedDepths,afMeanEmiAtDpeth(:),'gd');

% figure(13);
% clf;
% plot(afSortedDepths,afMeanEmiAtDpeth(:)./afMeanExcAtDpeth(:),'r');


figure(13);
clf;
plot(afSortedDepths,afMeanEmiAtDpeth(aiSortInd) ./ afMeanExcAtDpeth(aiSortInd),'r');
return
 
 %%
 function Res=fnCheckForFilesExistence(acFileList)
     Res = true;
for k=1:length(acFileList)
    if ~exist(acFileList{k},'file')
        fprintf('File is missing : %s\n',acFileList{k});
        Res = false;
    end
end
