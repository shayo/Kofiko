function [varargout] = fnRunSpikeMonitor()

[g_strctPlexon.m_iServerID] = PL_InitClient(0);

strctPTB.hPTBWindow = Screen('OpenWindow',3);
strctPTB.m_aiPTBWindowResolution = Screen('Resolution',3);
strctPlexon.m_aiPlottingWindow = [1,1,strctPTB.m_aiPTBWindowResolution.width/2,strctPTB.m_aiPTBWindowResolution.height/2];

Screen('CloseAll');

while isRunning












end






return;

function fnUpdateTrialCircularBuffer(SpikesFromPlexon,SpikeTimeStamps,trialCondition)
global g_strctPlexon


		% Reset the location in the buffer and add the newest trial
		g_strctPlexon.m_strctSpikeBuffer.m_aiSpikes...
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
	
	


return;


function [data] = fnGetDataFromPlexonCircularBuffer(buffer, bufferIDs, numElementsToExtract)


for i = 1:size(buffer,2)
	if bufferIDs(i) - numElementsToExtract <= 0
		dataIDs = [1:bufferIDs(i), (bufferIDs(i) - numElementsToExtract+1)+size(buffer,3):size(buffer,3)];
		data(:,i,1:numElementsToExtract) = buffer(:,i,dataIDs);
	else
		data(:,i,1:numElementsToExtract) = buffer(:,i,[bufferIDs(i)-numElementsToExtract+1:bufferIDs(i)]);
	end

end

return;