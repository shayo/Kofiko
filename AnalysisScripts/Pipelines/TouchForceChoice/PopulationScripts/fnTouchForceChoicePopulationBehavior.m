function fnTouchForceChoicePopulationBehavior(acDataEntries)
global g_acDataCache
% This block loads the data from disk (or uses the cache if data was
% already loaded
if ~isempty(g_acDataCache) && length(g_acDataCache) == length(acDataEntries)
    fprintf('Loading Data from cache...');
    acData = g_acDataCache;
    fprintf('Done!\n');
else
    fprintf('Loading Data from disk...');
    acData = fnLoadDataEntries(acDataEntries); % Forget about attributes, just load everything.
    fprintf('Done!\n');
    g_acDataCache = acData;
end

fnNewBehaviorAnalysis(acData);

%%
a2cCompareTrials = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};

bDraw = true;

iNumExperiments = length(acDailyStat);
iNumContrasts = size(a2cCompareTrials,1);
a2fPValues = zeros(iNumExperiments,iNumContrasts);
a2iNumTrials= zeros(iNumExperiments,iNumContrasts);
abSubject = zeros(1,iNumExperiments);
for iExpIter = 1:iNumExperiments
    
    [~,strSubj]=fnFindAttribute(acDailyStat{iExpIter }.m_a2cAttributes,'Subject');
    abSubject(iExpIter) = strcmpi(strSubj,'Julien');
    [~,strTime]=fnFindAttribute(acDailyStat{iExpIter }.m_a2cAttributes,'TimeDate');
    [~,strDesign]=fnFindAttribute(acDailyStat{iExpIter }.m_a2cAttributes,'Design');
    
    %fprintf('%d trials in total\n',length(acDailyStat{iExpIter}.m_aiTrialTypeMappedToUnique));
    iNumOutcomes = length(acDailyStat{iExpIter}.m_acUniqueOutcomes);
    
    % Merge all trials ?
    afPValueU = zeros(1,8);
    afPValueT = zeros(1,8);
    aiNumTrials = zeros(1,8);
    for iDirIter=1:iNumContrasts
        iIndexNoStim = find(ismember(lower(acDailyStat{iExpIter}.m_acUniqueTrialNames), lower(a2cCompareTrials{iDirIter,1})));
        iIndexStim = find(ismember(lower(acDailyStat{iExpIter}.m_acUniqueTrialNames), lower(a2cCompareTrials{iDirIter,2})));
        if isempty(iIndexNoStim) || isempty(iIndexStim)
            continue;
        end;
        aiStimTrialsInd = find(acDailyStat{iExpIter}.m_aiTrialTypeMappedToUnique == iIndexStim);
        aiNonStimTrialsInd = find(acDailyStat{iExpIter}.m_aiTrialTypeMappedToUnique == iIndexNoStim);
        aiOutcomesStim = acDailyStat{iExpIter}.m_aiTrialOutcomeMappedToUnique(aiStimTrialsInd);
        aiOutcomesNonStim = acDailyStat{iExpIter}.m_aiTrialOutcomeMappedToUnique(aiNonStimTrialsInd);
        aiNumTrials(iDirIter) = length(aiStimTrialsInd)+length(aiNonStimTrialsInd);
        [afPValueU(iDirIter),h]=ranksum(aiOutcomesStim, aiOutcomesNonStim);
        [h,afPValueT(iDirIter)]=kstest2(aiOutcomesStim, aiOutcomesNonStim);
    end
    a2iNumTrials(iExpIter,:) = aiNumTrials;
    a2fPValues(iExpIter,:) = afPValueU;
    a2fPValuesKS(iExpIter,:) = afPValueT;
    
    if bDraw
    h=figure(10+iExpIter);
    set(h,'Name',sprintf('%s - %s - %s',strSubj,strDesign,strTime));
    clf;
    for iDirIter = 1:size(a2cCompareTrials,1)
       iIndexNoStim = find(ismember(lower(acDailyStat{iExpIter}.m_acUniqueTrialNames), lower(a2cCompareTrials{iDirIter,1})));
        iIndexStim = find(ismember(lower(acDailyStat{iExpIter}.m_acUniqueTrialNames), lower(a2cCompareTrials{iDirIter,2})));
         
        tightsubplot(2,4, iDirIter,'Spacing',0.1);
        a2fStat = [    acDailyStat{iExpIter}.m_a2fNumTrialsNormalized(iIndexNoStim,:);    acDailyStat{iExpIter}.m_a2fNumTrialsNormalized(iIndexStim,:)];
        bar(a2fStat,'stacked');
        title(sprintf('%d %s',iDirIter,a2cCompareTrials{iDirIter,1}));
        if iDirIter==size(a2cCompareTrials,1)
            legend(acDailyStat{iExpIter}.m_acUniqueOutcomes,'Location','South');
        end
    end
    end
    
end
[a2fPValues < 0.05, abSubject']
% dbg = 1;

% figure(11);clf;
% plot(cumsum(a2iDistBootstrapNoStim)-cumsum(a2iDistBootstrapStim),'Linewidth',2)
%
% hold on;
% plot(cumsum(a2iDistBootstrapStim),'--','Linewidth',2);legend(acDailyStat{iExpIter}.m_acUniqueOutcomes)
%
return;



%% Bootstrapping code...


for iDirIter=1:size(a2cCompareTrials,1)
    iIndexNoStim = find(ismember(lower(acDailyStat{iExpIter}.m_acUniqueTrialNames), lower(a2cCompareTrials{iDirIter,1})));
    iIndexStim = find(ismember(lower(acDailyStat{iExpIter}.m_acUniqueTrialNames), lower(a2cCompareTrials{iDirIter,2})));
    
    aiStimTrialsInd = find(acDailyStat{iExpIter}.m_aiTrialTypeMappedToUnique == iIndexStim);
    aiNonStimTrialsInd = find(acDailyStat{iExpIter}.m_aiTrialTypeMappedToUnique == iIndexNoStim);
    
    % bootstrap the distributions....
    % Pick N trials at random and check how many have the desired outcome
    aiOutcomesStim = acDailyStat{iExpIter}.m_aiTrialOutcomeMappedToUnique(aiStimTrialsInd);
    aiOutcomesNonStim = acDailyStat{iExpIter}.m_aiTrialOutcomeMappedToUnique(aiNonStimTrialsInd);
    
    figure(10);clf;hold on;
    plot(aiOutcomesStim,'.')
    plot(aiOutcomesNonStim,'ro')
    
    M = 10000;
    N = 50;
    iNumStimTrials = length(aiOutcomesStim);
    iNumNonStimTrials = length(aiOutcomesNonStim);
    a2iBootStrapStim = randi(iNumStimTrials,M,N);
    a2iBootStrapNoStim = randi(iNumNonStimTrials,M,N);
    % a2iBootstrapOutcomesStim rows correspond to a random experiment
    % (1...10000) in which N trials were chosen (say, 20), all for the
    % same trial type. The values are the outcomes.
    a2iBootstrapOutcomesStim = aiOutcomesStim(a2iBootStrapStim);
    a2iBootstrapOutcomesNoStim = aiOutcomesNonStim(a2iBootStrapNoStim);
    % Each one of the columns correspond to acDailyStat{iExpIter}.m_acUniqueOutcomes
    a2iDistBootstrapStim = zeros(1+N, iNumOutcomes);
    a2iDistBootstrapNoStim = zeros(1+N, iNumOutcomes);
    afPvalueT = zeros(1,iNumOutcomes);
    afPvalueU = zeros(1,iNumOutcomes);
    afPvalueKS = zeros(1,iNumOutcomes);
    for iOutcome=1:iNumOutcomes
        aiBootstrapOutcomeStim = sum(a2iBootstrapOutcomesStim==iOutcome,2);
        aiBootstrapOutcomeNoStim = sum(a2iBootstrapOutcomesNoStim==iOutcome,2);
        a2iDistBootstrapStim(:,iOutcome) = histc(aiBootstrapOutcomeStim,0:N);
        a2iDistBootstrapNoStim(:,iOutcome) = histc(aiBootstrapOutcomeNoStim,0:N);
        [~,afPvalueKS((iOutcome))]=kstest2(aiBootstrapOutcomeStim,aiBootstrapOutcomeNoStim);
        [~,afPvalueT((iOutcome))]=ttest(aiBootstrapOutcomeStim,aiBootstrapOutcomeNoStim);
        [afPvalueU((iOutcome))]=ranksum(aiBootstrapOutcomeStim,aiBootstrapOutcomeNoStim);
    end
end




function fnNewBehaviorAnalysis(acData)
a2cCompareTrials = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};


afContrastValue = fnReadContrastValues(acData);

acTrialNames=a2cCompareTrials(:,1);
a3fTrialStats_NoStim = fnExtractTrialStats(acData,a2cCompareTrials(:,1));

dbg = 1;

function a3fTrialStats = fnExtractTrialStats(acData,acTrialNames)
iNumDataEntries = length(acData);
iNumTrialTypes = length(acTrialNames);
a3fTrialStats = zeros(iNumTrialTypes,5,iNumDataEntries); % [Num trials, Num correct, Num Incorrect, Num Aborted, Num Timeout]

for iDataEntryIter=1:iNumDataEntries
    
    iNumAllTrialTypes = length(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes);
    acAllTrialNames = cell(1, iNumAllTrialTypes);
    aiMapToOutput = ones(1, iNumAllTrialTypes) * NaN;
    
    for iTrialTypeIter=1:iNumAllTrialTypes
        acAllTrialNames{iTrialTypeIter} =  acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams.Name;
        iOutputIndex = find(ismember(acTrialNames, acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams.Name));
        if ~isempty(iOutputIndex)
            aiMapToOutput(iTrialTypeIter) = iOutputIndex;
        end
    end
     
    iNumTrials = length(acData{iDataEntryIter}.strctDesignStat.m_acTrials);
    a2fPerformance = zeros(iNumTrialTypes,5); % [Num trials, Num correct, Num Incorrect, Num Aborted, Num Timeout]

    for iTrialIter=1:iNumTrials 
        iOutputIndex = aiMapToOutput(acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_iTrialType);
        if ~isnan(iOutputIndex)
            a2fPerformance(iOutputIndex,1) = a2fPerformance(iOutputIndex,1) + 1;
            switch acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome
                case 'Correct'
                    a2fPerformance(iOutputIndex,2) = a2fPerformance(iOutputIndex,2) + 1;
                case 'Incorrect'
                    a2fPerformance(iOutputIndex,3) = a2fPerformance(iOutputIndex,3) + 1;
                case 'Aborted'
                    a2fPerformance(iOutputIndex,4) = a2fPerformance(iOutputIndex,4) + 1;
                case 'Timeout'
                    a2fPerformance(iOutputIndex,5) = a2fPerformance(iOutputIndex,5) + 1;
                otherwise
                    fprintf('Unknown trial type %s\n',acData{iDataEntryIter}.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome);
            end
        end
    end
    a3fTrialStats(:,:,iDataEntryIter) = a2fPerformance;
end

return


function afContrastValue = fnReadContrastValues(acData)
iNumDataEntries = length(acData);
afContrastValue = zeros(1,iNumDataEntries);
acCueFile = cell(1,iNumDataEntries);
for iDataEntryIter=1:iNumDataEntries
    % Find one trial to infer contrast...
    for iTrialTypeIter=1:length(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes)
        if strcmpi(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.TrialParams.Name,'SaccadeTaskLeft')
            iMediaIndex = find(ismember(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acMediaName,...            
                acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_acTrialTypes{iTrialTypeIter}.Cue.CueMedia));
            acCueFile{iDataEntryIter} = acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName;
            Tmp=imread(acData{iDataEntryIter}.strctDesignStat.m_strctDesign.m_astrctMedia(iMediaIndex).m_strFileName);
            afContrastValue(iDataEntryIter)= max(max(Tmp(:,:,1)));
            break;
        end
    end
end
return;