function acUnitsStat = fnAnalyzeForceChoiceBehaviorStatistics(strctKofiko,strctConfig)
% This function will analyze ALL trials, but will call special analysis
% functions per design.

if isfield(strctConfig,'m_acSpecificAnalysis') && ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end

iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Force Choice');
if isempty(iParadigmIndex)
    % No trials found.
    acUnitsStat = [];
    return;
end
    
    
if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'acTrials')
    % No trials found.
    acUnitsStat = [];
    return;
end
acUnitsStat = cell(0);

% Find out how many unique designs were actually run.
acUniqueDesignNames = unique(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer);
assert( length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.TimeStamp) == ...
    length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.TimeStamp));

iNumUniqueDesigns = length(acUniqueDesignNames);

% For the trials for each design
afDesignTS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.TimeStamp;
afDesignTS(end+1) = Inf; % We don't really know when the last design ended... Maybe when we shutdown or when we swiched to another paradigm.

iOutputIter=1;
for iDesignIter=1:iNumUniqueDesigns
    strDesignName = acUniqueDesignNames{iDesignIter};
    
    aiDesignOnsets = find(ismember(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer,strDesignName));
    afDesignOnsetsTS_Kofiko = afDesignTS(aiDesignOnsets);
    afDesignOffsetsTS_Kofiko = afDesignTS(aiDesignOnsets+1);
    iNumTimesDesignRun = length(afDesignOnsetsTS_Kofiko);
    
    [strctSpecialDesign] = fnMatchSpecialDesignAnalysisAndDisplay(strctConfig,strDesignName);
    
    aiTrialInd = [];
    for iIter=1:iNumTimesDesignRun
        % find the corresponding trials between onset and offset
        aiTrialInd = [aiTrialInd,    find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp >=afDesignOnsetsTS_Kofiko(iIter) & ...
            strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp <=afDesignOffsetsTS_Kofiko(iIter))];
    end
    
    
    if ~isempty(aiTrialInd)
        Tmp  = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{aiDesignOnsets(1)};
        if ~isempty(Tmp)
            astrctTrialsType = Tmp{1};
            astrctChoices = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{aiDesignOnsets(1)}{2};
            acTrials = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiTrialInd);
            
            strctStatistics = fnCollectStandardForceChoiceTrialStatistics(...
                strDesignName,acTrials,astrctTrialsType,astrctChoices, strctKofiko, strctConfig);
            
            strctStatistics.m_strDisplayFunction =strctConfig.m_strctGeneral.m_strBehaviorDisplayScript;
            
            if ~isempty(strctSpecialDesign) && isfield(strctSpecialDesign.m_strctParams,'m_strSpecialAnalysisBehaviorScript')
                % Call User defined analysis functions...
                strctStatistics = feval(strctSpecialDesign.m_strctParams.m_strSpecialAnalysisBehaviorScript,...
                    strctStatistics, acTrials,astrctTrialsType,astrctChoices, strctKofiko, strctSpecialDesign);
                
                if isfield(strctSpecialDesign.m_strctParams,'m_strSpecialDisplayBehaviorScript')
                    strctStatistics.m_strDisplayFunction  = strctSpecialDesign.m_strctParams.m_strSpecialDisplayBehaviorScript;
                end
            end
            
            strctStatistics.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
            
            acUnitsStat{iOutputIter} = strctStatistics;
            iOutputIter = iOutputIter + 1;
        end
    end
    
    
end

return;

function strctStatistics = fnCollectStandardForceChoiceTrialStatistics(strDesignName,acTrials,astrctTrialsType,astrctChoices, strctKofiko, strctConfig)
% Standard performance and latency analysis

% Behavior Statistics ?
strctStatistics.m_strParadigm = 'Force Choice';
[strP,strF]=fileparts(strDesignName);
strctStatistics.m_strParadigmDesc = strF;
strctStatistics.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctStatistics.m_strDesignName = strDesignName;
iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Force Choice');

strctStatistics.m_iNumTrials = length(acTrials);
strctStatistics.m_iNumCorrect = 0;
strctStatistics.m_iNumIncorrect = 0;
strctStatistics.m_iNumShortHold = 0;
strctStatistics.m_iNumTimeout = 0;

if isfield(strctKofiko.g_strctDAQParams,'StimulusServerSync')
    SyncTime = strctKofiko.g_strctDAQParams.StimulusServerSync;
else
    SyncTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime;
end
strctStatistics.m_afResponseTimeSec = NaN*ones(1,strctStatistics.m_iNumTrials);
strctStatistics.m_afNoiseLevels =  zeros(1,strctStatistics.m_iNumTrials);
for k=1:strctStatistics.m_iNumTrials
    strctTrial = acTrials{k};
    if length(strctTrial.m_fTrialOnset_TS_StimulusServer) == 2
        strctTrial.m_fTrialOnset_TS_StimulusServer(3) = strctTrial.m_fTrialOnset_TS_StimulusServer(2);
    end;
    
    strctStatistics.m_afNoiseLevels(k) = strctTrial.m_fNoiseLevel;
    switch strctTrial.m_strResult
        case 'Correct'
            strctStatistics.m_iNumCorrect = strctStatistics.m_iNumCorrect + 1;
            strctStatistics.m_afResponseTimeSec(k) = ...
                strctTrial.m_fTrialEndTimeLocal-fnStimulusServerTimeToKofikoTime(SyncTime, ...
                strctTrial.m_fTrialOnset_TS_StimulusServer(3));
            
        case 'Incorrect'
            strctStatistics.m_iNumIncorrect = strctStatistics.m_iNumIncorrect + 1;
            strctStatistics.m_afResponseTimeSec(k) = ...
                strctTrial.m_fTrialEndTimeLocal-fnStimulusServerTimeToKofikoTime(SyncTime, ...
                strctTrial.m_fTrialOnset_TS_StimulusServer(3));
            
        case 'ShortHold'
            strctStatistics.m_iNumShortHold = strctStatistics.m_iNumShortHold + 1;
        case 'Timeout'
            strctStatistics.m_iNumTimeout = strctStatistics.m_iNumTimeout + 1;
        otherwise
            assert(false);
    end
end

% Response Time
abValidTrials = ~isnan(strctStatistics.m_afResponseTimeSec);
strctStatistics.m_fMeanResponseTimeMS = 1e3*mean(strctStatistics.m_afResponseTimeSec(abValidTrials));
strctStatistics.m_fStdResponseTimeMS = 1e3*std(strctStatistics.m_afResponseTimeSec(abValidTrials));

% Performance as a function of noise level
aiNoiseLevelBins = 0:10:100;
[aiNumTrialsInBin, aiIndices]=histc(strctStatistics.m_afNoiseLevels,aiNoiseLevelBins);

aiActiveBins = find(aiNumTrialsInBin> 0);
aiNumTrialsInActiveBins = aiNumTrialsInBin(aiActiveBins);
iNumActiveBins = length(aiActiveBins);
afPercCorrect = zeros(1,iNumActiveBins);
for iBinIter=1:iNumActiveBins
    aiSelectedTrials = find(aiIndices == aiActiveBins(iBinIter) & abValidTrials);
    if ~isempty(aiSelectedTrials)
        acResult= fnCellStructToArray(acTrials(aiSelectedTrials),'m_strResult');
        iNumCorrect = sum(ismember(acResult,'Correct'));
        iNumIncorrect = sum(ismember(acResult,'Incorrect'));
    end
    afPercCorrect(iBinIter) = iNumCorrect/(iNumCorrect+ iNumIncorrect);
end

strctStatistics.m_strctPerformance.m_afNoiseLevels = aiNoiseLevelBins(aiActiveBins);
strctStatistics.m_strctPerformance.m_afPercCorrect = afPercCorrect;
strctStatistics.m_strctPerformance.m_aiNumTrialsPerBin = aiNumTrialsInActiveBins;
return;