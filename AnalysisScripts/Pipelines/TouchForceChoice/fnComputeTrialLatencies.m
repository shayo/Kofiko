function fnComputeTrialLatencies()       
for iTrialIter=1:iNumSameTrialType
            iTrialIndex = aiRelevantTrials(iTrialIter);
            if isfield(strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome,'m_afSelectedChoiceTS') && ...
                isfield(strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
                afLatency(iTrialIter) = strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome.m_afSelectedChoiceTS(1)-...
                strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko;
            elseif isfield(strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome,'m_afCueOnset_TS_Kofiko') && isfield(strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome,'m_fTrialAbortedTS_Kofiko')
                % Trial was aborted during cue presentation / memory
                % period?
                % Report latency as time until break fixation...
                afLatency(iTrialIter) = strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome.m_fTrialAbortedTS_Kofiko-strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome.m_afCueOnset_TS_Kofiko(1);
            elseif isfield(strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome,'m_afCueOnset_TS_Kofiko') && ~isfield(strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome,'m_fTrialAbortedTS_Kofiko')
                % Timeout ?
                afLatency(iTrialIter) = strctParadigm.acTrials.TimeStamp(iTrialIndex)- strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko;
            else
                
                % Break before first cue appeared (?)
                 % old version files don't have information about trial
                 % abort....
                 % Extrapolate this information from other pieces of
                 % information (if available)
                fTrialOver_TS = strctParadigm.acTrials.TimeStamp(iTrialIndex); 
                fFixationAppeared = strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctTrialOutcome.m_fFixationSpotFlipTS_Kofiko;
                fTimeToFixate = strctParadigm.acTrials.Buffer{iTrialIndex}.m_strctPreCueFixation.m_fPreCueFixationPeriodMS/1e3;
                afLatency(iTrialIter) = fTrialOver_TS - (fFixationAppeared+fTimeToFixate);
            end
end