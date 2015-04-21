function fnParadigmForcedChoiceSendDefaultStat()
global g_strctParadigm
TRIAL_START_CODE = 32700;
TRIAL_END_CODE = 32699;
TRIAL_ALIGN_CODE = 32698;
TRIAL_OUTCOME_CORRECT = 32697;
TRIAL_OUTCOME_INCORRECT = 32696;
TRIAL_OUTCOME_BREAKFIX = 32695;
TRIAL_OUTCOME_TIMEOUT_NODECISION = 32694;

strctDesign.TrialStartCode = TRIAL_START_CODE;
strctDesign.TrialEndCode = TRIAL_END_CODE;
strctDesign.TrialAlignCode = TRIAL_ALIGN_CODE;
strctDesign.TrialOutcomesCodes = [TRIAL_OUTCOME_BREAKFIX,TRIAL_OUTCOME_INCORRECT,TRIAL_OUTCOME_CORRECT,TRIAL_OUTCOME_TIMEOUT_NODECISION];
strctDesign.KeepTrialOutcomeCodes = [TRIAL_OUTCOME_CORRECT,TRIAL_OUTCOME_INCORRECT];
strctDesign.TrialTypeToConditionMatrix = [];
strctDesign.ConditionOutcomeFilter = cell(0);
strctDesign.NumTrialsInCircularBuffer = 200;

fTimeOut = fnTsGetVar(g_strctParadigm,'TimeoutMS')/1e3;
fHoldFixationToStartTrial = fnTsGetVar(g_strctParadigm,'HoldFixationToStartTrialMS')/1e3;
fDelayBeforeChoices = fnTsGetVar(g_strctParadigm,'DelayBeforeChoicesMS')/1e3;
fMemoryInterval= fnTsGetVar(g_strctParadigm,'MemoryIntervalMS')/1e3;
fFixationTimeOut = fnTsGetVar(g_strctParadigm,'FixationTimeOutMS')/1e3;

strctDesign.TrialLengthSec = max(fFixationTimeOut, fHoldFixationToStartTrial+ fDelayBeforeChoices + fMemoryInterval + fTimeOut);
strctDesign.Pre_TimeSec = 0.5;
strctDesign.Post_TimeSec = 0.5;
% Default statistics. Correct and incorrect.
% all trial types go in all conditions.
% Conditions are defined by trial outcomes.
NumTrialTypes = length(g_strctParadigm.m_astrctTrials);
NumConditions = 2;
strctDesign.TrialTypeToConditionMatrix = ones(NumTrialTypes,NumConditions) > 0; 
strctDesign.ConditionOutcomeFilter = cell(1,2);
strctDesign.ConditionOutcomeFilter{1} = TRIAL_OUTCOME_CORRECT;
strctDesign.ConditionOutcomeFilter{2} = TRIAL_OUTCOME_INCORRECT;
strctDesign.ConditionNames = {'Correct Trial','Incorrect Trial'};
[strDummy,strctDesign.DesignName]= fileparts(fnTsGetVar(g_strctParadigm,'DesignFileName'));
g_strctParadigm.m_strctStatServerDesign = strctDesign;
if fnParadigmToStatServerComm('IsConnected')
    fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);
end

return;