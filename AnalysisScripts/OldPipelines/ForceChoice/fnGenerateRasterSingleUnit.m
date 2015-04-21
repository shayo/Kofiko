function [strctRaster] = fnGenerateRasterSingleUnit(acTrials, fBlurMS,strTitle)
iNumTrials = length(acTrials);
if iNumTrials == 0
    strctRaster = [];
    return;
end

iBeforeMS = max(fnCellStructToArray(acTrials, 'm_iBeforeMS'));
iAfterMS =max(fnCellStructToArray(acTrials, 'm_iAfterMS'));

strctRaster.m_aiRasterTimeMS = -iBeforeMS:iAfterMS;
strctRaster.m_a2bRaster = zeros(iNumTrials,length(strctRaster.m_aiRasterTimeMS),'uint8')>0;
for iTrialIter=1:iNumTrials
    fSyncTime = acTrials{iTrialIter}.m_fCenterImageON_PlexonTS;
    afSpikesDuringTrial = acTrials{iTrialIter}.m_afSpikes;
    if ~isempty(afSpikesDuringTrial)
        afSpikesRelativeToSyncVar = afSpikesDuringTrial - fSyncTime;
        aiSpikeBins = 1+iBeforeMS+round(afSpikesRelativeToSyncVar * 1e3);
        strctRaster.m_a2bRaster(iTrialIter,1+aiSpikeBins(aiSpikeBins >=1  & (aiSpikeBins < size(strctRaster.m_a2bRaster,2)))) = true;

    end 
end

if fBlurMS > 0
    afSmoothingKernelMS = fspecial('gaussian',[1 7*fBlurMS],fBlurMS);
    %afSmoothingKernelMS = ones(1,fBlurMS)/fBlurMS;
    strctRaster.m_a2fRaster = single(conv2(double(strctRaster.m_a2bRaster), afSmoothingKernelMS,'same') * 1e3);
    strctRaster = rmfield(strctRaster,'m_a2bRaster');
end
    
strctRaster.m_afCenterImageOFF_TrialTS = fnCellStructToArray(acTrials, 'm_fCenterImageOFF_PlexonTS') - fnCellStructToArray(acTrials, 'm_fCenterImageON_PlexonTS');
strctRaster.m_afDecisionsImageON_TrialTS = fnCellStructToArray(acTrials, 'm_fDecisionsImageON_PlexonTS') - fnCellStructToArray(acTrials, 'm_fCenterImageON_PlexonTS');
strctRaster.m_afSaccade_TrialTS = fnCellStructToArray(acTrials, 'm_fMonkeySaccade_PlexonTS') - fnCellStructToArray(acTrials, 'm_fCenterImageON_PlexonTS');
strctRaster.m_strTitle = strTitle;
strctRaster.m_afNoiseLevel = fnCellStructToArray(acTrials, 'm_fNoiseLevel');

if isfield(acTrials{1},'m_afLFP')
    % Compute the average LFP for this trial
    iNumLFPSamples = length(acTrials{1}.m_afLFP);
    a2fAvgLFP = zeros(iNumTrials,iNumLFPSamples);
    for iTrialIter=1:iNumTrials
        a2fAvgLFP(iTrialIter,:) = acTrials{iTrialIter}.m_afLFP;
    end   
    strctRaster.m_afAvgLFP = nanmean(a2fAvgLFP,1);
    strctRaster.m_afStdLFP = nanstd(a2fAvgLFP,1);
end
return;