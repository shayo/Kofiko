function fnUpdateTrialCircularBuffer(trialOutcome,trialDirection,trialCondition)
global g_strctParadigm




		%trialDirection = round(trialDirection/5)

		% Reset the location in the buffer and add the newest trial
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBuffer...
				(:, trialCondition,g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBufferIDs(trialCondition)) = 0;
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBuffer...
							(trialOutcome, trialCondition, g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBufferIDs(trialCondition)) = 1;
							
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBuffer...
				(:, trialDirection,g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBufferIDs(trialDirection)) = 0;
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBuffer...
							(trialOutcome, trialDirection, g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBufferIDs(trialDirection)) = 1;				
							
		% Update buffer Index
		
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBufferIDs...
				(trialCondition) = ...
				g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBufferIDs(trialCondition) + 1;
				
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBufferIDs...
				(trialDirection) = ...
				g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBufferIDs(trialDirection) + 1;
		
		
		% Reset buffer indices that have exceeded the buffer size
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBufferIDs(g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularColorBufferIDs > ...	
																		 squeeze(g_strctParadigm.TrialsInBuffer.Buffer(:,1,g_strctParadigm.TrialsInBuffer.BufferIdx))) = 1;
		
		
		g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBufferIDs(g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBufferIDs >  ...	
																		 squeeze(g_strctParadigm.TrialsInBuffer.Buffer(:,1,g_strctParadigm.TrialsInBuffer.BufferIdx))) = 1;
		
		%{
		if g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularBufferIDs(trialDirection,trialCondition) >= squeeze(g_strctParadigm.TrialsInBuffer.Buffer(:,1,g_strctParadigm.TrialsInBuffer.BufferIdx));
			g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularBufferIDs(trialDirection,trialCondition) = 1;
		end
%}
	
	


return;