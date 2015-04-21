function acUnitsStat = fnAnalyzeTargetDetectionBehaviorStatistics(strctKofiko,strctConfig)

if isfield(strctConfig,'m_acSpecificAnalysis') && ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end

iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Target Detection');

if isempty(iParadigmIndex) || ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'acTrials') 
    % No trials found.
    acUnitsStat = [];
    return;
end




% Find out how many unique designs were actually run.
acUniqueDesignNames = unique(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ListFileName.Buffer);
assert( length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ObjectNames.TimeStamp) == ...
        length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ObjectNames.TimeStamp));
    
iNumUniqueDesigns = length(acUniqueDesignNames);

% For the trials for each design
afDesignTS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ListFileName.TimeStamp;
afDesignTS(end+1) = Inf; % We don't really know when the last design ended... Maybe when we shutdown or when we swiched to another paradigm.

iOutputIter=1;
for iDesignIter=1:iNumUniqueDesigns
    strDesignName = acUniqueDesignNames{iDesignIter};

    aiDesignOnsets = find(ismember(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ListFileName.Buffer,strDesignName));
    afDesignOnsetsTS_Kofiko = afDesignTS(aiDesignOnsets);
    afDesignOffsetsTS_Kofiko = afDesignTS(aiDesignOnsets+1);
    iNumTimesDesignRun = length(afDesignOnsetsTS_Kofiko);
    
    strctSpecialDesignAnalysis = fnMatchSpecialDesignAnalysisAndDisplay(strctConfig,strDesignName);

    aiTrialInd = [];
    for iIter=1:iNumTimesDesignRun
        % find the corresponding trials between onset and offset
       aiTrialInd = [aiTrialInd,    find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp >=afDesignOnsetsTS_Kofiko(iIter) & ...
                  strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp <=afDesignOffsetsTS_Kofiko(iIter))];
    end
    

    if ~isempty(aiTrialInd) && ~( length(aiTrialInd) == 1 && aiTrialInd == 1)
         acObjectNames = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ObjectNames.Buffer{aiDesignOnsets(1)};
         astrctTrials = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiTrialInd);
         
         
         strctStatistics = fnCollectStandardTargetDetectionTrialStatistics(...
             astrctTrials,acObjectNames, strctKofiko, strctConfig);

        
        
        strctStatistics.m_strDisplayFunction = strctConfig.m_strctGeneral.m_strBehaviorDisplayScript;
        
         if ~isempty(strctSpecialDesignAnalysis) && isfield(strctSpecialDesignAnalysis.m_strctParams,'m_strSpecialAnalysisBehaviorScript')
                strctStatistics = feval(strctSpecialDesignAnalysis.m_strctParams.m_strSpecialAnalysisBehaviorScript, strctStatistics, astrctTrials,acObjectNames, strctKofiko, strctConfig);
         end
         
         if ~isempty(strctSpecialDesignAnalysis) && isfield(strctSpecialDesignAnalysis.m_strctParams,'m_strSpecialDisplayBehaviorScript')
               strctStatistics.m_strDisplayFunction = strctSpecialDesignAnalysis.m_strctParams.m_strSpecialDisplayBehaviorScript;
         end
         
        strctStatistics.m_strListUsed = strDesignName;
        strctStatistics.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
        strctStatistics.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
        strctStatistics.m_strParadigm = 'Target Detection';
        [strPath,strFileName]=fileparts(strDesignName);
        strctStatistics.m_strParadigmDesc = strFileName;
        acUnitsStat{iOutputIter} = strctStatistics;
        iOutputIter = iOutputIter + 1;

    end
    

end

return;
% afLocalTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,1);
% afRemoteTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,2);
% strctUnit.m_fJitterMS = mean(1e3*strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,3));
% strctUnit.m_afTimeTrans = [afRemoteTime ones(size(afRemoteTime))] \ afLocalTime;
% afStimulusServerFlip_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.Buffer(iStartFlipInd:iLastFlipInd-1,1);
% strctUnit.m_afStimulusOnsetTS =  strctUnit.m_afTimeTrans(1)*afStimulusServerFlip_TS + strctUnit.m_afTimeTrans(2);


acUnitsStat{1} = strctUnit;

return;

function strctStatistics = fnCollectStandardTargetDetectionTrialStatistics(astrctTrials,acObjectNames, strctKofiko, strctConfig)
if isempty(astrctTrials{1})
    astrctTrials = astrctTrials(2:end);
end;

strctStatistics.m_iNumTrials = length(astrctTrials);
strctStatistics.m_abCorrect = zeros(1,strctStatistics.m_iNumTrials)>0;
strctStatistics.m_abIncorrect = zeros(1,strctStatistics.m_iNumTrials)>0;
strctStatistics.m_abShortHold = zeros(1,strctStatistics.m_iNumTrials)>0;
strctStatistics.m_abTimeout = zeros(1,strctStatistics.m_iNumTrials)>0;
strctStatistics.m_afLatency = zeros(1,strctStatistics.m_iNumTrials);
strctStatistics.m_aiNumTargets = zeros(1,strctStatistics.m_iNumTrials);
strctStatistics.m_aiNumDistractors = zeros(1,strctStatistics.m_iNumTrials);
strctStatistics.m_aiDecidedObject =  zeros(1,strctStatistics.m_iNumTrials);
strctStatistics.m_afTimeout = zeros(1,strctStatistics.m_iNumTrials);
for iTrialIter=1:strctStatistics.m_iNumTrials
   strctTrial = astrctTrials{iTrialIter};
   
   if isfield(strctTrial,'m_fTimeoutTimer')
       fStimulusOnset = strctTrial.m_fTimeoutTimer;
   else
       fStimulusOnset = strctTrial.m_fFlipStimulusON_TS_Local;
   end
   
   if isfield(strctTrial,'m_fSaccadeToObjectTSLocal')
       fDecisionTime = strctTrial.m_fSaccadeToObjectTSLocal;
   else
       % Infer decision time from time the trial ended. Take into
       % consideration "hold at target"
       fDecisionTime = strctTrial.m_fTrialEndTimeLocal - strctTrial.m_fHoldTimeSec;
   end
   strctStatistics.m_afLatency(iTrialIter) = fDecisionTime-fStimulusOnset;
   strctStatistics.m_aiNumDistractors(iTrialIter) = length(strctTrial.m_aiSelectedNonTargets);
   strctStatistics.m_aiNumTargets(iTrialIter) = length(strctTrial.m_aiSelectedTargets);
   if isfield(strctTrial,'m_iGazedAtObject')
       strctStatistics.m_aiDecidedObject(iTrialIter) = strctTrial.m_iGazedAtObject;
   else
    strctStatistics.m_aiDecidedObject(iTrialIter) = -1;
   end
   strctStatistics.m_afTimeout(iTrialIter) = strctTrial.m_fTimeOutSec;
   switch strctTrial.m_strResult
       case 'Correct'
           strctStatistics.m_abCorrect(iTrialIter) = 1;
       case 'Incorrect'
           strctStatistics.m_abIncorrect(iTrialIter) = 1;
       case 'ShortHold'
           strctStatistics.m_abShortHold(iTrialIter) = 1;
       case 'Timeout'
           strctStatistics.m_abTimeout(iTrialIter) = 1;
       otherwise
           assert(false);
   end   
end

return;


function Value = fnGetValueAtExperimentStart(strctTsVar, fTimestamp)
iIndex = find(strctTsVar.TimeStamp <= fTimestamp,1,'last');
if isempty(iIndex)
    Value = [];
else
    if iscell(strctTsVar.Buffer)
        Value = strctTsVar.Buffer{iIndex};
    else
        Value = strctTsVar.Buffer(iIndex,:);
    end
end
return;


return;