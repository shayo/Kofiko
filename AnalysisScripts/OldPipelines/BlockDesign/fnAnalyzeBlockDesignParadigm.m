function acUnitsStat = fnAnalyzeBlockDesignParadigm(strctKofiko, strctConfig)
% Collect information from fMRI block design experiment.
% There isn't really a "unit", but we can still extract meaningful
% information about monkey performance from gaze tracks...
%
%
    fnWorkerLog('Behavioral data analysis for fMRI Block design during the ENTIRE experiment is not yet implemented.');
    acUnitsStat = [];
    return;

% if isempty(strctSession)
% end;
iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'fMRI Block Design');

strctUnit.m_strDisplayFunction = 'fnDisplayBlockDesignExperiment';
strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strctUnit.m_strParadigmDesc = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_acExperimentDescription{iSessionIter};
strctUnit.m_iRecordedSession = iSessionIter;
strctUnit.m_iChannel = -1;
strctUnit.m_iUnitID = -1;
strctUnit.m_fDurationMin = (strctSession.m_fKofikoEndTS-strctSession.m_fKofikoStartTS)/60;
strctUnit.m_strParadigm = 'fMRI Block Design';
strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctUnit.m_strctConfig = strctConfig;
% Extract information about which images were displayed and when....
strctUnit.m_acBlocks = fnGetValueAtExperimentStart(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.BlockRunOrder, strctSession.m_fKofikoStartTS);
strctUnit.m_iNumTRsPerBlock = fnGetValueAtExperimentStart(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.NumTRsPerBlock, strctSession.m_fKofikoStartTS);
strctUnit.m_fTR_MS =  fnGetValueAtExperimentStart(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.TR,strctSession.m_fKofikoStartTS);
strctUnit.m_aiImageList = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RecordedRun.Buffer{iSessionIter+1}{1};
strctUnit.m_afDisplayTimeMS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RecordedRun.Buffer{iSessionIter+1}{2};
assert(length(strctUnit.m_aiImageList) == length(strctUnit.m_afDisplayTimeMS));

iStartFlipInd = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.TimeStamp >= strctSession.m_fKofikoStartTS,1,'first');
iLastFlipInd = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.TimeStamp <= strctSession.m_fKofikoEndTS,1,'last');

iNumFlips = iLastFlipInd-iStartFlipInd+1;
if (iNumFlips-1 ~= length(strctUnit.m_aiImageList))
    fnWorkerLog('Experiment %d was aborted before all images were displayed! ',iSessionIter);    
end

%strctUnit.m_aiImageList = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RecordedRun.Buffer{iSessionIter+1}{1};
strctUnit.m_afDisplayTimeMS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RecordedRun.Buffer{iSessionIter+1}{2};

strctUnit.m_aiDisplayedImages = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.Buffer(iStartFlipInd:iLastFlipInd-1,2);
%afStimulusServerFlip_Counter =strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.Buffer(iStartFlipInd:iLastFlipInd,3);
%afKofikoFlip_TS =strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.TimeStamp(iStartFlipInd:iLastFlipInd);

% Find the transformation to go from stimulus server timing to kofiko
% timing

afLocalTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,1);
afRemoteTime = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,2);
strctUnit.m_fJitterMS = mean(1e3*strctKofiko.g_astrctAllParadigms{iParadigmIndex}.SyncTime.Buffer(2:end,3));
strctUnit.m_afTimeTrans = [afRemoteTime ones(size(afRemoteTime))] \ afLocalTime;
afStimulusServerFlip_TS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FlipTime.Buffer(iStartFlipInd:iLastFlipInd-1,1);
strctUnit.m_afStimulusOnsetTS =  strctUnit.m_afTimeTrans(1)*afStimulusServerFlip_TS + strctUnit.m_afTimeTrans(2);

strctUnit.m_afDrawAttentionEventsTS = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp >=strctSession.m_fKofikoStartTS & ...
     strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp <=strctSession.m_fKofikoEndTS);

strctUnit.m_afStimulusSizeRadPix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix.Buffer, strctUnit.m_afStimulusOnsetTS);

strctUnit.m_afFixationSizePix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSizePix.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSizePix.Buffer, strctUnit.m_afStimulusOnsetTS);
 
strctUnit.m_afRotationAngleDeg = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle.TimeStamp, ...
           strctKofiko.g_astrctAllParadigms{iParadigmIndex}.RotationAngle.Buffer, strctUnit.m_afStimulusOnsetTS);

%        aiTmp = find(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp >= strctSession.m_fKofikoStartTS & ...
%            strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp <= strctSession.m_fKofikoEndTS);
% Analyze gaze tracks...
fEyeTrackingSamplingRateHz = 60;
afMRITime = strctSession.m_fKofikoStartTS:1/fEyeTrackingSamplingRateHz:strctSession.m_fKofikoEndTS;
afEyeXraw = fnMyInterp1(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp,strctKofiko.g_strctEyeCalib.EyeRaw.Buffer(:,1), afMRITime);
afEyeYraw = fnMyInterp1(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp,strctKofiko.g_strctEyeCalib.EyeRaw.Buffer(:,2), afMRITime);

afOffsetX = fnMyInterp1(strctKofiko.g_strctEyeCalib.CenterX.TimeStamp,strctKofiko.g_strctEyeCalib.CenterX.Buffer, afMRITime);
afOffsetY = fnMyInterp1(strctKofiko.g_strctEyeCalib.CenterY.TimeStamp,strctKofiko.g_strctEyeCalib.CenterY.Buffer, afMRITime);
afGainX = fnMyInterp1(strctKofiko.g_strctEyeCalib.GainX.TimeStamp,strctKofiko.g_strctEyeCalib.GainX.Buffer, afMRITime);
afGainY = fnMyInterp1(strctKofiko.g_strctEyeCalib.GainY.TimeStamp,strctKofiko.g_strctEyeCalib.GainY.Buffer, afMRITime);

% The way to convert Raw Eye signal from kofiko to screen coordinates is:
%afEyeXpix = (afEyeXraw - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
%afEyeYpix = (afEyeYraw - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;

strctUnit.m_afDistToFixationSpot = sqrt( ((afEyeXraw - afOffsetX).*afGainX).^2 + ((afEyeYraw - afOffsetY).*afGainY).^2);

% estimate monkey's performance per image presentation and per block.

iNumImagesPresented = length(strctUnit.m_afStimulusOnsetTS);
strctUnit.m_abCorrectTrial = zeros(1,iNumImagesPresented);
strctUnit.m_afAvgEyePosFromFixationSpot = zeros(1,iNumImagesPresented);
for k=1:iNumImagesPresented
    aiInd = find(afMRITime >= strctUnit.m_afStimulusOnsetTS(k) & afMRITime <= strctUnit.m_afStimulusOnsetTS(k)+strctUnit.m_afDisplayTimeMS(k)/1e3);
    strctUnit.m_abCorrectTrial(k) = sum(strctUnit.m_afDistToFixationSpot(aiInd) < strctConfig.m_fCorrectTrialDistanceFromFixationSpot) / length(aiInd) > strctConfig.m_fFixationPercThreshold/100;
    strctUnit.m_afAvgEyePosFromFixationSpot(k) = median(strctUnit.m_afDistToFixationSpot(aiInd));
end
strctUnit.m_fCorrectTrialPerc = sum(strctUnit.m_abCorrectTrial)/iNumImagesPresented;

iNumBlocks = length(strctUnit.m_acBlocks);
strctUnit.m_fBlockLengthSec = strctUnit.m_iNumTRsPerBlock * strctUnit.m_fTR_MS/1e3;
for iBlockIter=1:iNumBlocks
    fBlockStartTime = strctUnit.m_afStimulusOnsetTS(1) +  strctUnit.m_fBlockLengthSec * (iBlockIter-1);
    fBlockEndTime = strctUnit.m_afStimulusOnsetTS(1) +  strctUnit.m_fBlockLengthSec * (iBlockIter);
    aiInd = find(afMRITime >= fBlockStartTime & afMRITime <= fBlockEndTime);
    strctUnit.m_abCorrectBlock(iBlockIter) = sum(strctUnit.m_afDistToFixationSpot(aiInd) < strctConfig.m_fCorrectTrialDistanceFromFixationSpot) / length(aiInd) > strctConfig.m_fCorrectBlockFixationPercThreshold/100;
end
strctUnit.m_fCorrectBlockPerc = sum(strctUnit.m_abCorrectBlock)/iNumBlocks;

%

acUnitsStat{1} = strctUnit;

return;



