function strctStatistics = fnAnalyzeForceChoiceClassificationImage(strctStatistics, astrctTrials,astrctTrialsType,astrctChoices, strctKofiko, strctConfig)
iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Force Choice');
fTimestamp = astrctTrials{1}.m_fTrialStartTimeLocal;
strNoiseFile = fnGetValueAtExperimentStart(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.NoiseFile, fTimestamp);
% Assume the same noise file was run through out ALL experiments.
if ~exist(strNoiseFile,'file')
    [strP,strF,strE] = fileparts(strNoiseFile);
    strNoiseFile = [strctConfig.m_strctParams.m_strAlternativeNoiseFolder ,strF,strE];
    assert(exist(strNoiseFile,'file') > 0)
end

strctNoise = load(strNoiseFile);
iNumTrials = length(astrctTrials);
aiMonkeySelection = zeros(1,iNumTrials);
abValidTrial = ones(1,iNumTrials) >0;
aiNoiseIndex = zeros(1,iNumTrials);
for iTrialIter=1:iNumTrials
    if ~strcmpi(astrctTrials{iTrialIter}.m_strResult,'ShortHold')
        aiMonkeySelection(iTrialIter)=astrctTrials{iTrialIter}.m_iMonkeySaccadeToTargetIndex;
        aiNoiseIndex(iTrialIter) = astrctTrials{iTrialIter}.m_iNoiseIndex;
    else
        abValidTrial(iTrialIter)=0;
    end
end


% Assume that astrctChoices(1) is FaceRight and astrctChoices(2) is
% NoiseLeft
assert(strcmpi(astrctChoices(1).m_strName,'FaceRight') && strcmpi(astrctChoices(2).m_strName,'NoiseLeft'))
iNumValidTrials = sum(abValidTrial);
aiAnswerFace = find(aiMonkeySelection == 1);
aiAnswerNoise = find(aiMonkeySelection == 2);

aiNoiseWhenAnswerFace = aiNoiseIndex(aiAnswerFace);
aiNoiseWhenAnswerNoise = aiNoiseIndex(aiAnswerNoise);

strctStatistics.m_a2fAvgYes = mean(strctNoise.a2fRand(:,:,aiNoiseWhenAnswerFace),3);
strctStatistics.m_a2fAvgNo = mean(strctNoise.a2fRand(:,:,aiNoiseWhenAnswerNoise),3);

strctStatistics.m_a2fPercpetiveField = strctStatistics.m_a2fAvgYes-strctStatistics.m_a2fAvgNo;


return;

