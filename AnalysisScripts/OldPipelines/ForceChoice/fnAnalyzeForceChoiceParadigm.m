function acUnitsStat = fnAnalyzeForceChoiceParadigm(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig)

if isfield(strctConfig,'m_acSpecificAnalysis') && ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end

% This function will analyze spiking data 

iParadigmIndex = fnFindParadigmIndex(strctKofiko, 'Force Choice');

if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'acTrials')
    % No trials found.
    acUnitsStat = [];
    return;
end


iNumUnits = length(strctPlexon.m_astrctUnits);

assert( length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.TimeStamp) == ...
    length(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.TimeStamp));

% Extract information about which design was used
iDesignIndexInBuffer = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.TimeStamp<= strctSession.m_fKofikoStartTS,1,'last');
strDesignName = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DesignFileName.Buffer{iDesignIndexInBuffer};
astrctTrialTypes = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndexInBuffer}{1};
astrctChoices = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.ExperimentDesigns.Buffer{iDesignIndexInBuffer}{2};

fnWorkerLog('Force Choice Experiment. Design : %s',strDesignName);

strctSpecialDesignAnalysis = fnMatchSpecialDesignAnalysisAndDisplay(strctConfig,strDesignName);

aiTrialInd = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp >=strctSession.m_fKofikoStartTS& ...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.TimeStamp <=strctSession.m_fKofikoEndTS);
if isempty(aiTrialInd)
    acUnitsStat = [];
    return;
end

acTrials = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.acTrials.Buffer(aiTrialInd);
acTrials = fnAppendTrialsWithChangableParams(acTrials,strctKofiko.g_astrctAllParadigms{iParadigmIndex},strctSession);
if strctConfig.m_strctParams.m_bAppendEyeTracesToSpecialAnalysisFunctions
    acTrials = fnAppendEyeTrace(acTrials, strctKofiko, strctPlexon,strctSession);
end
acTrials = fnAppendSpikes(acTrials, strctPlexon);

iOutputIter = 1;
for iUnitIter=1:iNumUnits
        strctUnit = fnStandardNeuralFiringRateAnalysis(acTrials, strctPlexon,strctKofiko, ...
            iUnitIter,strctSession,iSessionIter,strDesignName,astrctTrialTypes,astrctChoices,...
            strctConfig); 
      
        if ~isempty(strctUnit)
            if ~isempty(strctSpecialDesignAnalysis)
                strctUnit.m_strDisplayFunction = strctSpecialDesignAnalysis.m_strctParams.m_strSpecialDisplayScript;
                strctUnit = fnAppendWithSpecialRasters(strctUnit,acTrials,iUnitIter,strctSpecialDesignAnalysis,astrctTrialTypes,astrctChoices);
                if ~isempty(strctSpecialDesignAnalysis.m_strctParams.m_strSpecialAnalysisScript)
                    strctUnit = feval(strctSpecialDesignAnalysis.m_strctParams.m_strSpecialAnalysisScript,...
                        strctUnit, acTrials, strctPlexon,...
                        strctKofiko, iUnitIter, strctSession,iSessionIter,strDesignName,astrctTrialTypes,astrctChoices,...
                        strctConfig);
                end
            end
            
            acUnitsStat{iOutputIter} = strctUnit;
            iOutputIter = iOutputIter + 1;
        end
end


return;

function acTrials = fnAppendSpikes(acTrials, strctPlexon)
% Append only to correct or incorrect!
iNumTrials = length(acTrials);
iBeforeMS = max(fnCellStructToArray(acTrials, 'm_fHoldFixationToStartTrialMS'));
iMaxTimeoutMS = max(fnCellStructToArray(acTrials, 'm_fTimeoutMS'));
afTrialLength = fnCellStructToArray(acTrials, 'm_fMonkeySaccade_PlexonTS') - fnCellStructToArray(acTrials, 'm_fCenterImageON_PlexonTS');

iAfterMS = ceil(max(afTrialLength(afTrialLength < iMaxTimeoutMS/1e3)*1e3)) + max(fnCellStructToArray(acTrials, 'm_fShowObjectsAfterSaccadeMS'));
if isempty(iAfterMS)
    iAfterMS = 2000;
end;
iNumUnits = length(strctPlexon.m_astrctUnits);
for iTrialIter=1:iNumTrials
    fSyncTime = acTrials{iTrialIter}.m_fCenterImageON_PlexonTS;
    acTrials{iTrialIter}.m_iBeforeMS = iBeforeMS;
    acTrials{iTrialIter}.m_iAfterMS = iAfterMS;
    for iUnitIter=1:iNumUnits
        afSpikesDuringTrial = ...
            strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps(...
            strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps >= (fSyncTime-iBeforeMS/1e3) & ...
            strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps <= (fSyncTime+iAfterMS/1e3) );
        acTrials{iTrialIter}.m_acSpikes{iUnitIter} = afSpikesDuringTrial;
    end
end
return;


function acTrials = fnAppendEyeTrace(acTrials, strctKofiko, strctPlexon, strctSession)
iNumTrials = length(acTrials);

fSamplingFreq = strctPlexon.m_strctEyeX.m_fFreq;
iPlexonFrame = find(strctPlexon.m_strctEyeY.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
fEyeSamplingRate = 200; % Hz

for iTrialIter=1:iNumTrials
    % Add this information only to correct or incorrect trials...
    % Remove the "shorthold" and "timeout" trials.
    
    if strcmpi(acTrials{iTrialIter}.m_strResult,'Correct') ||  strcmpi(acTrials{iTrialIter}.m_strResult,'Incorrect') 
 
        fFixationPeriodBeforeSec = acTrials{iTrialIter}.m_fHoldFixationToStartTrialMS/1e3;
        fAfterDecisionPeriodSec =  acTrials{iTrialIter}.m_fShowObjectsAfterSaccadeMS/1e3;
        
        afTrialTimePlexon = acTrials{iTrialIter}.m_fCenterImageON_PlexonTS-fFixationPeriodBeforeSec:1/fEyeSamplingRate:acTrials{iTrialIter}.m_fMonkeySaccade_PlexonTS+fAfterDecisionPeriodSec;
        
        afOffsetX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterX, afTrialTimePlexon, strctSession);
        afOffsetY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterY, afTrialTimePlexon, strctSession);
        afGainX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainX, afTrialTimePlexon, strctSession);
        afGainY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainY, afTrialTimePlexon, strctSession);
        
        
        afPlexonFrameTime = strctPlexon.m_strctEyeY.m_afTimeStamp0(iPlexonFrame):1/fSamplingFreq:strctPlexon.m_strctEyeY.m_afTimeStamp0(iPlexonFrame)+...
            (strctPlexon.m_strctEyeY.m_aiNumSamplesInFragment(iPlexonFrame)-1)*1/fSamplingFreq;

        
        afEyeXraw = interp1(afPlexonFrameTime, ...
            strctPlexon.m_strctEyeX.m_afData(strctPlexon.m_strctEyeX.m_aiStart(iPlexonFrame):strctPlexon.m_strctEyeX.m_aiEnd(iPlexonFrame)),...
            afTrialTimePlexon)';
        
        afEyeYraw = interp1(afPlexonFrameTime, ...
            strctPlexon.m_strctEyeY.m_afData(strctPlexon.m_strctEyeY.m_aiStart(iPlexonFrame):strctPlexon.m_strctEyeY.m_aiEnd(iPlexonFrame)),...
            afTrialTimePlexon)';
        
        % The way to convert Raw Eye signal from plexon to screen coordinates is:
        acTrials{iTrialIter}.m_afEyeXpix = (afEyeXraw+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
        acTrials{iTrialIter}.m_afEyeYpix = (afEyeYraw+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
        acTrials{iTrialIter}.m_afEyeTimingPlexonTS = afTrialTimePlexon;

    end
end

return


function acTrials = fnAppendTrialsWithChangableParams(acTrials,strctParadigm,strctSession)
iNumTrials = length(acTrials);
for iTrialIter=1:iNumTrials
    % This 1x3 holds: Flip1,Flip2,Flip3
    % Flip1: Time when center image appeared on the screen
    % Flip2: Time when center image disappeared and a fixation appeared
    %        (delay period...)
    % Flip3: Time when targets appeared on screen
    
    afPlexonTS = fnStimulusServerTimeToPlexonTime(strctParadigm.SyncTime,strctSession,acTrials{iTrialIter}.m_fTrialOnset_TS_StimulusServer);
    
    
    acTrials{iTrialIter}.m_fCenterImageON_PlexonTS = afPlexonTS(1);
    if length(afPlexonTS) > 1
        acTrials{iTrialIter}.m_fCenterImageOFF_PlexonTS = afPlexonTS(2);
        
        if length(afPlexonTS) > 2
            acTrials{iTrialIter}.m_fDecisionsImageON_PlexonTS = afPlexonTS(3);
        else
            acTrials{iTrialIter}.m_fDecisionsImageON_PlexonTS = afPlexonTS(2);
        end
    end
        
    acTrials{iTrialIter}.m_fMonkeySaccade_PlexonTS = fnKofikoTimeToPlexonTime(strctSession,acTrials{iTrialIter}.m_fTrialEndTimeLocal);
    
    acTrials{iTrialIter}.m_fHoldFixationToStartTrialMS = fnMyInterp1(strctParadigm.HoldFixationToStartTrialMS.TimeStamp, ...
        strctParadigm.HoldFixationToStartTrialMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fDelayBeforeChoicesMS = fnMyInterp1(strctParadigm.DelayBeforeChoicesMS.TimeStamp, ...
        strctParadigm.DelayBeforeChoicesMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fMemoryIntervalMS = fnMyInterp1(strctParadigm.MemoryIntervalMS.TimeStamp, ...
        strctParadigm.MemoryIntervalMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fTimeoutMS = fnMyInterp1(strctParadigm.TimeoutMS.TimeStamp, ...
        strctParadigm.TimeoutMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fShowObjectsAfterSaccadeMS = fnMyInterp1(strctParadigm.ShowObjectsAfterSaccadeMS.TimeStamp, ...
        strctParadigm.ShowObjectsAfterSaccadeMS.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fImageHalfSizePix = fnMyInterp1(strctParadigm.ImageHalfSizePix.TimeStamp, ...
        strctParadigm.ImageHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fChoicesHalfSizePix = fnMyInterp1(strctParadigm.ChoicesHalfSizePix.TimeStamp, ...
        strctParadigm.ChoicesHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fChoicesHalfSizePix = fnMyInterp1(strctParadigm.ChoicesHalfSizePix.TimeStamp, ...
        strctParadigm.ChoicesHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
    
    acTrials{iTrialIter}.m_fChoicesHalfSizePix = fnMyInterp1(strctParadigm.ChoicesHalfSizePix.TimeStamp, ...
        strctParadigm.ChoicesHalfSizePix.Buffer, acTrials{iTrialIter}.m_fTrialStartTimeLocal);
end

return;

function strctUnit = fnStandardNeuralFiringRateAnalysis(acTrials, strctPlexon,...
    strctKofiko, iUnitIter,strctSession,iSessionIter,strDesignName,astrctTrialTypes,astrctChoices,...
    strctConfig) 
% Compute avg firing rate for "Correct" and "Incorrect" responses.
% Generate Raster ?
strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strctUnit.m_iRecordedSession = iSessionIter;
strctUnit.m_iChannel = strctPlexon.m_astrctUnits(iUnitIter).m_iChannel;
strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iUnitIter).m_iUnit;
strctUnit.m_fDurationMin = (strctSession.m_fKofikoEndTS-strctSession.m_fKofikoStartTS)/60;
strctUnit.m_strParadigm = 'Force Choice';
strctUnit.m_strDesignName = strDesignName;
[strPath,strFile]=fileparts(strDesignName);
strctUnit.m_strParadigmDesc = strFile;
strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctUnit.m_afAvgWaveForm = mean(strctPlexon.m_astrctUnits(iUnitIter).m_a2fWaveforms,1);
strctUnit.m_strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;

% Align everything to image onset

iNumTrials = length(acTrials);    
%aiTrialTypes = zeros(1,iNumTrials);
abCorrect = zeros(1,iNumTrials)>0;
abIncorrect = zeros(1,iNumTrials)>0;
for k=1:iNumTrials
    abCorrect(k) = strcmpi(acTrials{k}.m_strResult,'Correct') ;
    abIncorrect(k) = strcmpi(acTrials{k}.m_strResult,'Incorrect') ;
 %   aiTrialTypes(k) = acTrials{k}.m_iTrialDisplayed;
end

[strPath,strFile]=fileparts(strDesignName);
strctUnit.m_fSmoothnessKernelMS = 10;
[strctUnit.m_strctRasterCorrect] = fnGenerateRaster(acTrials(abCorrect),iUnitIter,strctUnit.m_fSmoothnessKernelMS,[strFile,': Correct (All Trials)']);
[strctUnit.m_strctRasterIncorrect] = fnGenerateRaster(acTrials(abIncorrect),iUnitIter,strctUnit.m_fSmoothnessKernelMS,[strFile,': Incorrect (All Trials)']);

% 
% for iTrialIter=1:length(aiValidTrials)
%     iTrialIndex = aiValidTrials(iTrialIter);
%     
%    fStartPlexonTS = acTrials{iTrialIndex}.m_fCenterImageON_PlexonTS-acTrials{iTrialIndex}.m_fHoldFixationToStartTrialMS/1e3;
%    fEndPlexonTS = acTrials{iTrialIndex}.m_fMonkeySaccade_PlexonTS +acTrials{iTrialIndex}.m_fShowObjectsAfterSaccadeMS/1e3;
%    
%    acTrials{iTrialIndex}.m_afSpikesDuringTrial = ...
%        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps(...
%        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps >= fStartPlexonTS & ...
%        strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps <= fEndPlexonTS);
%    
%    if 0
%        afEyeVelocity = [0;sqrt(diff(acTrials{iTrialIndex}.m_afEyeXpix).^2+diff(acTrials{iTrialIndex}.m_afEyeYpix).^2)];
%        afEyeVelocity = afEyeVelocity / max(afEyeVelocity);
%        
%        % Display Trial Information
%        figure(11);
%        clf;hold on;
%        h0=plot(acTrials{iTrialIndex}.m_afEyeTimingPlexonTS,2+afEyeVelocity,'k');
%        for k=1:length(acTrials{iTrialIndex}.m_afSpikesDuringTrial)
%            plot(acTrials{iTrialIndex}.m_afSpikesDuringTrial(k) * ones(1,2),[0 1],'b');
%        end
%        h1=plot(acTrials{iTrialIndex}.m_fCenterImageON_PlexonTS * ones(1,2),[0 5],'r');
%        h2=plot(acTrials{iTrialIndex}.m_fCenterImageOFF_PlexonTS * ones(1,2),[0 5],'g');
%        h3=plot(acTrials{iTrialIndex}.m_fDecisionsImageON_PlexonTS* ones(1,2),[0 5],'c');
%        h4=plot(acTrials{iTrialIndex}.m_fMonkeySaccade_PlexonTS* ones(1,2),[0 5],'m');
%        legend([h0,h1,h2,h3,h4],{'Eye Velocity','Center Image ON','Center Image OFF','Decisions ON','Saccade'});
%        
%        strCenterImage = astrctTrialTypes(acTrials{iTrialIndex}.m_iTrialDisplayed).m_strImageFileName;
%        text(acTrials{iTrialIndex}.m_fCenterImageON_PlexonTS,1.5,strCenterImage, 'BackgroundColor',[0 0 0],'color',[1 1 1]);
%        text(acTrials{iTrialIndex}.m_fMonkeySaccade_PlexonTS,1.5,acTrials{iTrialIter}.m_strResult, 'BackgroundColor',[0 0 0],'color',[1 1 1]);
%    end
%    
% end
% 
% 
return;




function strctUnit = fnAppendWithSpecialRasters(strctUnit,acTrials,iUnitIter,strctSpecialDesignAnalysis,astrctTrialTypes,astrctChoices)
if ~isfield(strctSpecialDesignAnalysis,'m_acRaster')
    return;
end;
iNumRasters = length(strctSpecialDesignAnalysis.m_acRaster);
iNumTrials = length(acTrials);
for iRasterIter=1:iNumRasters
    % Select the trials that match the creteria given in the XML
    
    
    
    abTrialsUsed = zeros(1,iNumTrials) > 0;
    bCrashed = false;
    for iTrialIter=1:iNumTrials
         
        if ~isempty(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strResponse)
            bResultHit = strcmpi(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strResponse,acTrials{iTrialIter}.m_strResult);
        else
            bResultHit = true;
        end
        
        if isfield(strctSpecialDesignAnalysis.m_acRaster{iRasterIter},'m_strNoiseSelection') && ~isempty(strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strNoiseSelection)
            strString = strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strNoiseSelection;
            strString(strString == 'L') = '<';
            strString(strString == 'G') = '>';
            strString(strString == 'E') = '=';
            
            strCondition = ['bNoiseHit = acTrials{iTrialIter}.m_fNoiseLevel ',strString,';'];
            
            try
                eval(strCondition);
            catch
                bCrashed = true;
                bNoiseHit = false;
            end
            
            
        else
            bNoiseHit = true;
        end
            
        bTrialIndexHit = sum(acTrials{iTrialIter}.m_iTrialDisplayed == strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_aiTrialSelectionIndices) > 0;
        strTrialName = astrctTrialTypes(acTrials{iTrialIter}.m_iTrialDisplayed).m_strImageFileName;
        aiStartInd = regexpi(strTrialName, strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strTrialSelectionNames);
        bRegularExpressionHit = ~isempty(aiStartInd);
        abTrialsUsed(iTrialIter) = (bTrialIndexHit || bRegularExpressionHit) && bResultHit && bNoiseHit;
    end
    if bCrashed
        fnWorkerLog('CRITICAL ERROR: crashed while trying to evaluate the noise level argument for a special raster');
    end
    
    strctUnit.m_acRasters{iRasterIter} = fnGenerateRaster(acTrials(abTrialsUsed), ...
        iUnitIter, strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_fSmoothingMS,...
        strctSpecialDesignAnalysis.m_acRaster{iRasterIter}.m_strName);
    
end

return;
