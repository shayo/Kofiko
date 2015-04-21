function [afResponses]=fnGetResponses(strctUnit, aiStimuli,fStartMS,fEndMS)
iStatInd = find(strctUnit.m_aiPeriStimulusRangeMS>=fStartMS,1,'first');
iEndInd = find(strctUnit.m_aiPeriStimulusRangeMS>=fEndMS,1,'first');
aiInd = find(ismember(strctUnit.m_aiStimulusIndexValid,aiStimuli));
afKernel = fspecial('gaussian',[1 100], 15);
a2bRasterSmooth= conv2(double(strctUnit.m_a2bRaster_Valid(aiInd,:)),afKernel,'same');
afResponses = 1e3*mean( a2bRasterSmooth(:,iStatInd:iEndInd),2);
return;
