function acUnitsStat = fnAnalyzeOddOneOutBehaviorStatistics(strctKofiko,strctConfig)

acUnitsStat = [];
fnWorkerLog('Collecting data for Odd One Out paradigm...');


iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Touch Odd One Out');
if isempty(iParadigmIndex)
    return;
end;
acstrNumDesignsUsed = unique(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer);

% Analyze per design
afDesignTS = [strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.TimeStamp(:)',Inf];
for iDesignIter=1:length(acstrNumDesignsUsed)
    strDesignName = acstrNumDesignsUsed{iDesignIter};
    aiDesignInd = find(ismember(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer,strDesignName));
    acTrials = [];
    for iIter=1:length(aiDesignInd)
        fStartTS = afDesignTS(aiDesignInd(iIter));
        fEndTS = afDesignTS(aiDesignInd(iIter)+1);
    
    % Aggregate all trials
        aiRelevantTrialInd = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp >= fStartTS &....
                                  strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp <= fEndTS);
     if ~isempty(aiRelevantTrialInd)
            acTrials = [acTrials, strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiRelevantTrialInd)];
     end
     
    end
    if ~isempty(acTrials) && isempty(acTrials{1})
        acTrials = acTrials(2:end);
    end;

    % Collect general purpose statistics, and possibly specific statistics
    % based on the design
    if ~isempty(acTrials)
        acUnitsStat = [acUnitsStat,fnCollectStandardOddOneOutStats(strDesignName,acTrials, strctKofiko, strctConfig,iParadigmIndex)];
    end
end

return;




function acStatistics = fnCollectStandardOddOneOutStats(strDesignName,acTrials, strctKofiko, strctConfig,iParadigmIndex)
% Standard performance and latency analysis

% Behavior Statistics ?
strctStatistics.m_strParadigm = 'Touch Odd One Out';
[strP,strF]=fileparts(strDesignName);
strctStatistics.m_strParadigmDesc = strF;
strctStatistics.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctStatistics.m_strDesignName = strDesignName;
strctStatistics.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strctStatistics.m_iNumTrials = length(acTrials);
strctStatistics.m_iNumCorrect = 0;
strctStatistics.m_iNumIncorrect = 0;
strctStatistics.m_iNumTimeout = 0;
strctStatistics.m_strDisplayFunction = strctConfig.m_strctGeneral.m_strBehaviorDisplayScript;
strctStatistics.m_afResponseTimeSec = NaN*ones(1,strctStatistics.m_iNumTrials);

abValidTrial = zeros(1,strctStatistics.m_iNumTrials)>0;
abCorrect = zeros(1,strctStatistics.m_iNumTrials)>0;
aiCatSame = zeros(1,strctStatistics.m_iNumTrials);
aiCatDiff = zeros(1,strctStatistics.m_iNumTrials);
for k=1:strctStatistics.m_iNumTrials
    strctTrial = acTrials{k};
     
    switch strctTrial.m_strResult
        case 'Correct'
            strctStatistics.m_iNumCorrect = strctStatistics.m_iNumCorrect + 1;
            strctStatistics.m_afResponseTimeSec(k) = strctTrial.m_fMonkeyTouch_TS - strctTrial.m_fImagesAppear_TS;
            aiCatSame(k) = strctTrial.m_iCatSame;
            aiCatDiff(k) = strctTrial.m_iCatDiff;
            abValidTrial(k) = true;
            abCorrect(k) = true;
        case 'Incorrect'
            aiCatSame(k) = strctTrial.m_iCatSame;
            aiCatDiff(k) = strctTrial.m_iCatDiff;
            strctStatistics.m_iNumIncorrect = strctStatistics.m_iNumIncorrect + 1;
            strctStatistics.m_afResponseTimeSec(k) = strctTrial.m_fMonkeyTouch_TS - strctTrial.m_fImagesAppear_TS;
            abValidTrial(k) = true;
        case 'TimeOut'
            strctStatistics.m_iNumTimeout = strctStatistics.m_iNumTimeout + 1;
            abValidTrial(k) = false;
        otherwise
            assert(false);
    end
end

aiCatSameValid =aiCatSame(abValidTrial);
aiCatDiffValid =aiCatDiff(abValidTrial); 
abCorrectValid = abCorrect(abValidTrial); 

% Running performance?
strctStatistics.m_afRunningAvg = conv( double(abCorrectValid), fspecial('gaussian',[1 40], 10),'same');
% Load design
strctDesign = load([strctConfig.m_strctParams.m_strAlternativePathForDesign,strF,'.mat']);
iNumCategories = length(strctDesign.acCategories);
% Build the confusion matrix 
strctStatistics.m_strctDesign = strctDesign;
strctStatistics.m_acCatNames = strctDesign.acCategories;
strctStatistics.m_a2fConfusionMatrix = zeros(iNumCategories,iNumCategories);
strctStatistics.m_a2iNumTrials = zeros(iNumCategories,iNumCategories);
for iSame=1:iNumCategories
    % Correct Category for the similar stimulus
    for iDiff=1:iNumCategories
        % Category for the odd object
            % compute performance across this category
            abRelevantTrials = aiCatDiffValid == iDiff & aiCatSameValid == iSame;
            iNumTrials = sum(abRelevantTrials);
            if iNumTrials > 0
                strctStatistics.m_a2fConfusionMatrix(iSame,iDiff) = sum(abCorrectValid(abRelevantTrials)) / iNumTrials;
                strctStatistics.m_a2iNumTrials(iSame,iDiff) = iNumTrials;
            end
    end
end
acStatistics = {strctStatistics};
return;
