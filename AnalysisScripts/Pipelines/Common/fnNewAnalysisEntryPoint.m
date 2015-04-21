%strRawFolder = 'C:\Users\shayo\Dropbox\RAW\';
%strRawFolder = 'D:\Dropbox\My Dropbox\RAW\';
strRawFolder = 'D:\Data\Doris\Electrophys\Houdini\Targeting ML and PL 2011\New Recordings New Format\110511\RAW';

%strSession = '110506_152934_Houdini';
strSession = '110511_154714_Houdini';

strKofikoFile = fullfile(strRawFolder,[strSession,'.mat']);
strAdvancerFile = fullfile(strRawFolder,[strSession,'-Advancers.txt']);
strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strStrobeFile = fullfile(strRawFolder,[strSession,'-strobe.raw']);
strAnalogFile = fullfile(strRawFolder,[strSession,'-EyeX.raw']);  % any can suffice...
%% Sync all computers
strSyncFile = fullfile(strRawFolder,[strSession,'-sync.mat']);
if ~exist(strSyncFile,'file')
    strctSync = fnAnalysisSyncComputers(strStrobeFile, strAnalogFile,strKofikoFile, strStatServerFile);
    save(strSyncFile,'strctSync');
else
    load(strSyncFile,'strctSync');
end

%%
% Read Active Unit information
% [Channel, Unit, ON/OFF, PlexonFrame, TS_PlxFrame, TS_MAPclock, TS_PTB]
strActiveUnitsFile = fullfile(strRawFolder,[strSession,'-ActiveUnits.txt']);
if exist(strActiveUnitsFile,'file')
    a2fActiveUnitsTable = textread(strActiveUnitsFile);
else
    a2fActiveUnitsTable = [];
end
astrctUnitIntervals = fnActiveUnitTableToIntervals(a2fActiveUnitsTable, strctSync,strSession,strRawFolder);

%%
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'DataBrowser.xml'));
iNumAnalyses = length(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis);
acAnalysesParadigmName = cell(1,iNumAnalyses);
for iParadigmIter=1:iNumAnalyses
    acAnalysesParadigmName{iParadigmIter} =  strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iParadigmIter}.m_strctGeneral.m_strParadigmName;
end


strctKofiko = load(strKofikoFile);
afParadigmSwitchTS_Kofiko = strctKofiko.g_strctAppConfig.ParadigmSwitch.TimeStamp;
acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;

%%
iNumSortedUnits = length(astrctUnitIntervals);
acUnitsStat = [];
for iUnitIter=1:iNumSortedUnits
    
    fStartTS_PTB_Kofiko = fnTimeZoneChange(astrctUnitIntervals(iUnitIter).m_fStartTS_Plexon,strctSync,'Plexon','Kofiko');
    fEndTS_PTB_Kofiko = fnTimeZoneChange(astrctUnitIntervals(iUnitIter).m_fEndTS_Plexon,strctSync,'Plexon','Kofiko');
    % Find out which paradigms were run while this unit was alive...
    iStartIndex = find(afParadigmSwitchTS_Kofiko <= fStartTS_PTB_Kofiko,1,'last');
    iEndIndex = find(afParadigmSwitchTS_Kofiko <= fEndTS_PTB_Kofiko,1,'last');
    acParadigmsRecorded = unique(acstrParadigmNames(iStartIndex:iEndIndex));

    
    for iParadigmIter=1:length(acParadigmsRecorded)
          iAnalysisIndex = find(ismember(acAnalysesParadigmName,  acParadigmsRecorded{iParadigmIter}));
          if isempty(iAnalysisIndex)
              fprintf('Failed to find analyses pipeline for paradigm %s\n',acParadigmsRecorded{iParadigmIter});
          else
              % Replace this....
            acUnitsStat = [acUnitsStat,...
                feval(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iAnalysisIndex}.m_strctGeneral.m_strStatisticsFunction, ...
                 strctKofiko,strctSync, strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iAnalysisIndex},astrctUnitIntervals(iUnitIter)) ];
          end
    end
    
    
    
end
%%

acUnits=acUnitsStat
aiSelectedUnits = [];
save('Test.mat','acUnits','aiSelectedUnits','-v7.3');

%%


% Read Advancer information
% [AdvancerID, DepthMM, PlxFrame, TS_PlxFrame, TS_MAPclock, TS_PTB]
if exist(strAdvancerFile,'file')
    a2fAdvancersTable = textread(strAdvancerFile);
else
    a2fAdvancersTable = [];
end

%%
aiActiveChannels = [1,2];
NumChannels = length(aiActiveChannels);
NumUnits = 5; % 4 + unsorted...
for ChIter=1:NumChannels
    Ch = aiActiveChannels(ChIter);
    
    a2fWaves = [];
    afTS = [];
    aiCol = [];
    for Unit=0:4
        try
            [n, npw, afUnitTS, a2fUnitWaves] = plx_waves(strPLXfile, Ch, Unit);
            a2fWaves = [a2fWaves;a2fUnitWaves];
            afTS = [afTS; afUnitTS];
            aiCol = [aiCol; ones(n,1)*Unit];
        catch
            
        end
    end
    astrctChannels(ChIter).m_a2fWaves = a2fWaves;
    astrctChannels(ChIter).m_afTS = afTS;
    astrctChannels(ChIter).m_aiRealTimeSort = aiCol;
end

% Parse kofikof file...
iSelectedChannel = 1;
[coeff, score, latent, tsquare] = princomp(astrctChannels(iSelectedChannel).m_a2fWaves);
a2fWaves0 = bsxfun(@minus,astrctChannels(1).m_a2fWaves,mean(astrctChannels(iSelectedChannel).m_a2fWaves,1));
a2fWavesProj = a2fWaves0 * coeff(:,1:2);
N = size(a2fWavesProj,1);
W =  2000; % 4001 spikes interval
Tskip = 100;
figure(1);
clf;
Xmin = min(a2fWavesProj(:,1));
Xmax = max(a2fWavesProj(:,1));
Ymin = min(a2fWavesProj(:,2));
Ymax = max(a2fWavesProj(:,2));
strCol='kygcr';
for t=1:Tskip:N
    clf;
    hold on;
    aiRange = max(1,t-W):min(N,t+W);
    for j=0:4
        aiSubUnit = find(astrctChannels(iSelectedChannel).m_aiRealTimeSort(aiRange) == j);
        plot(a2fWavesProj(aiRange(aiSubUnit),1),a2fWavesProj(aiRange(aiSubUnit),2),'.','color',strCol(j+1));
    end
    axis([Xmin,Xmax,Ymin,Ymax]);
    drawnow
end
