function fFirstCueOnsetTS_Kofiko =  fnGetApproximatedCueOnsetTimeForOldTrialTypes(strctTrial)
% Silly thing. In very old log files I did not explicitely saved when cues
% were flipped on the screen.
% This code tries to recover this information using all the other existing
% information.
% Basically, the time line is:
% Pre Cue fixation -> Cue1 Onset -> Cue 1 memory -> .... -> Memory period
% -> Choices onset.
%
fCueTimeMS = 0;
for k=1:length(strctTrial.m_astrctCueMedia)
        fCueTimeMS=fCueTimeMS+strctTrial.m_astrctCueMedia(k).m_fCuePeriodMS+strctTrial.m_astrctCueMedia(k).m_fCueMemoryPeriodMS;
end

if ~isempty(strctTrial.m_strctMemoryPeriod)
    fMemoryPeriodMS = strctTrial.m_strctMemoryPeriod.m_fMemoryPeriodMS;
else
    fMemoryPeriodMS = 0;
end

if isfield(strctTrial.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
    fFirstCueOnsetTS_Kofiko = strctTrial.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko - (fCueTimeMS+fMemoryPeriodMS)/1e3;
else
    % Really crappy situation. Aborted during cue presentation.
    fFirstCueOnsetTS_Kofiko = strctTrial.m_strctTrialOutcome.m_fFixationSpotFlipTS_Kofiko + strctTrial.m_strctPreCueFixation.m_fPreCueFixationPeriodMS/1e3;
end
        
  return;
  