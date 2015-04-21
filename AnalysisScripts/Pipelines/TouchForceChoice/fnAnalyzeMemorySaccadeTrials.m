function acTrials = fnAnalyzeMemorySaccadeTrials(acTrials,strctKofiko,strctSync,strRawFolder,strSession)

iNumTrials = length(acTrials);
if iNumTrials == 0
    astrctStats = [];
    return;
end;

for iTrialIndex=1:iNumTrials
        if isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_afSelectedChoiceTS')
            fSaccadeTSPlexon = fnTimeZoneChange(acTrials{iTrialIndex}.m_strctTrialOutcome.m_afSelectedChoiceTS(1), strctSync,'Kofiko','Plexon');
        else
            fSaccadeTSPlexon = NaN;
        end
        
        if isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_fChoicesOnsetTS_StatServer')
            fChoiceOnsetTSPlexon = fnTimeZoneChange(acTrials{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_StatServer, strctSync, 'StimulusServer','Plexon');
        else
            fChoiceOnsetTSPlexon = NaN;
        end
        
        if  isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_afCueOnset_TS_StimulusServer')
            fCueOnsetPlexon = fnTimeZoneChange( acTrials{iTrialIndex}.m_strctTrialOutcome.m_afCueOnset_TS_StimulusServer(1), strctSync, 'StimulusServer','Plexon');
        else
            if isfield(acTrials{iTrialIndex}.m_strctTrialOutcome,'m_fChoicesOnsetTS_Kofiko')
                fEstimatedCueOnsetKofikoTS = acTrials{iTrialIndex}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko-acTrials{iTrialIndex}.m_strctMemoryPeriod.m_fMemoryPeriodMS/1e3-acTrials{iTrialIndex}.m_astrctCueMedia(1).m_fCuePeriodMS/1e3;
                fCueOnsetPlexon = fnTimeZoneChange( fEstimatedCueOnsetKofikoTS, strctSync, 'Kofiko','Plexon');
            else
                fCueOnsetPlexon = NaN;
            end
        end
        
        fFixationOnsetPlexon = fnTimeZoneChange( acTrials{iTrialIndex}.m_strctTrialOutcome.m_fFixationSpotFlipTS_StimulusServer, strctSync, 'StimulusServer','Plexon');
        fFixationRequiredSec = acTrials{iTrialIndex}.m_strctPreCueFixation.m_fPreCueFixationPeriodMS/1e3;
        
        fConstantFixationOnsetPlexonTS = fCueOnsetPlexon-fFixationRequiredSec;
        
        
        strEyeXfile = [strRawFolder,filesep,strSession,'-EyeX.raw'];
        strEyeYfile = [strRawFolder,filesep,strSession,'-EyeY.raw'];

        fStartSamplingTS_PLX = fFixationOnsetPlexon-0.3;
        if isnan(fSaccadeTSPlexon)
            fEndSamplingTS_PLX = fFixationOnsetPlexon + 1;
        else
            fEndSamplingTS_PLX = fSaccadeTSPlexon+0.3;
        end
%         [strctEyeX_AllData, afPlexonTime_All] = fnReadDumpAnalogFile(strEyeXfile);
%         iStartIndx = find(afPlexonTime_All >= fStartSamplingTS_PLX,1,'first');
%         iEndIndx = find(afPlexonTime_All >= fEndSamplingTS_PLX,1,'first');
%         afPlexonTime2 = afPlexonTime_All(iStartIndx:iEndIndx);
%         strctEyeX2 = strctEyeX_AllData.m_afData(iStartIndx:iEndIndx);
%         figure(13);
%         clf;
%         plot(afPlexonTime2,strctEyeX2);
%         hold on;
%         plot( afPlexonTime,strctEyeX.m_afData,'r.');
        
        [strctEyeX, afPlexonTime] = fnReadDumpAnalogFile(strEyeXfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        [strctEyeY, afPlexonTime] = fnReadDumpAnalogFile(strEyeYfile,'Interval',[fStartSamplingTS_PLX,fEndSamplingTS_PLX]);
        % Convert the raw eye position to pixel coordinates.
      
        % Where was the fixation position?
        
        
        afOffsetX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afOffsetY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.CenterY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainX = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainX, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afGainY = fnTimeZoneChangeTS_Resampling(strctKofiko.g_strctEyeCalib.GainY, 'Kofiko','Plexon',afPlexonTime, strctSync);
        afEyeXpix = (strctEyeX.m_afData+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
        afEyeYpix = (strctEyeY.m_afData+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
    % median filter raw eye signal with a window of 1 ms to remove
    % outliers, then use bilateral filtering to keep edges but smooth the
    % signal elsewhere. 
    % These parameters work with 4000 Hz sampling... 
        fHighVelocityThreshold = 1.5; 
        fLowVelocityThreshold = 0.5; 
        iMinimumLength = 5;
        iMergeDistance = 60;
        iShortMergeDistance = 10;
        fAmplitudeThresholdPix = 25;
        afEyeXpix_smooth = fnBiLateral1D(medfilt1(afEyeXpix,5),70,60,30);
        afEyeYpix_smooth = fnBiLateral1D(medfilt1(afEyeYpix,5),70,60,30);
        
  
        iNumChoices =length(acTrials{iTrialIndex}.m_astrctChoicesMedia);
        abCorrect = zeros(1,iNumChoices)>0;
        for iChoiceIter=1:iNumChoices
            abCorrect(iChoiceIter) = acTrials{iTrialIndex}.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward;
        end
        iCorrectChoiceIndex = find(abCorrect,1,'first');
        pt2fCorrectChoicePosition = acTrials{iTrialIndex}.m_astrctChoicesMedia(iCorrectChoiceIndex). m_pt2fPosition;        
        
        
       afDistFromFixationSpot = sqrt( (afEyeXpix_smooth- acTrials{iTrialIndex}.m_strctPreCueFixation.m_pt2fFixationPosition(1)).^2+ ...
                                                      (afEyeYpix_smooth- acTrials{iTrialIndex}.m_strctPreCueFixation.m_pt2fFixationPosition(2)).^2);
    
        afDistFromTarget = sqrt( (afEyeXpix_smooth-pt2fCorrectChoicePosition(1)).^2+(afEyeYpix_smooth-pt2fCorrectChoicePosition(2)).^2);
        
         fMin = min([afDistFromFixationSpot(:);afDistFromTarget(:)]);
        fMax = max([afDistFromFixationSpot(:);afDistFromTarget(:)]);
        
        afEyeVelocity = sqrt( [0;diff(afEyeXpix_smooth).^2] + [0;diff(afEyeYpix_smooth).^2]);
          
          
        astrctIntervals = fnHysteresisThreshold(afEyeVelocity, fLowVelocityThreshold,fHighVelocityThreshold,  iMinimumLength,iShortMergeDistance);
        % Intervals of high eye velocity
        if isempty(astrctIntervals)
            % try lower thresholds...
            astrctIntervals = fnHysteresisThreshold(afEyeVelocity, fLowVelocityThreshold,fHighVelocityThreshold/2,  iMinimumLength,iShortMergeDistance);
            fAmplitudeThresholdPix = 20;
        end
        
        astrctSaccades = fnMergeIntervals(astrctIntervals, iMergeDistance);
        iAveragingInterval = 10; % Slightly before and after to approximate the stable position of the eye
         [afAllSaccadeAmplitude, a2fAllSaccadeDirection]= fnGetSaccadeAmplitudeAndDirection(astrctSaccades, afEyeXpix_smooth, afEyeYpix_smooth, iAveragingInterval);
         
         abLargeSaccades = afAllSaccadeAmplitude >= fAmplitudeThresholdPix;
        astrctSaccades = astrctSaccades(abLargeSaccades);
        afSaccadeAmplitude = afAllSaccadeAmplitude(abLargeSaccades);
        a2fSaccadeDirection = a2fAllSaccadeDirection(:,abLargeSaccades);
        
        % Discard saccades with amplitude smaller than X
        abSaccade = fnIntervalsToBinary(astrctSaccades, length(afEyeVelocity));
     
        if isempty(astrctSaccades)
            astrctStats(iTrialIndex).m_afSaccadeDirection = [NaN,NaN];
            astrctStats(iTrialIndex).m_fSaccadeAmplitude = NaN;
        else
            afSaccadeOnsetPlexon = afPlexonTime( cat(1,astrctSaccades.m_iStart));
            % Find the first saccade after the go signal
            if ~isnan(fChoiceOnsetTSPlexon)
                iIndex = find(afSaccadeOnsetPlexon > fChoiceOnsetTSPlexon,1,'first');
            else
                iIndex = find(afSaccadeOnsetPlexon > fFixationOnsetPlexon,1,'first');
            end
            
            if ~isempty(iIndex)
                astrctStats(iTrialIndex).m_afSaccadeDirection = a2fSaccadeDirection(:,iIndex);
                astrctStats(iTrialIndex).m_fSaccadeAmplitude = afSaccadeAmplitude(iIndex);
            else
                astrctStats(iTrialIndex).m_afSaccadeDirection = [NaN,NaN];
                astrctStats(iTrialIndex).m_fSaccadeAmplitude = NaN;
            end
        end
        
   if 1 % debug saccade detection
            afPlexonTime0 = afPlexonTime-afPlexonTime(1);
            
            fMinRange = min([afEyeXpix(:);afEyeYpix(:)]);
            fMaxRange = max([afEyeXpix(:);afEyeYpix(:)]);
            figure(12);
            clf;
            subplot(2,1,1);hold on;
            for j=1:length(astrctSaccades)
                rectangle('Position',[astrctSaccades(j).m_iStart, fMinRange astrctSaccades(j).m_iEnd-astrctSaccades(j).m_iStart,fMaxRange-fMinRange],'facecolor',[0.5 0.5 0.5]);
            end;
            plot(afEyeXpix,'b','LineWidth',2);
            plot(afEyeYpix,'g','LineWidth',2);
            plot(afEyeXpix_smooth,'r');
            plot(afEyeYpix_smooth,'k');
% 
%         for j=1:length(astrctSaccades)
%                 rectangle('Position',[afPlexonTime0(astrctSaccades(j).m_iStart), 0 afPlexonTime0(astrctSaccades(j).m_iEnd-astrctSaccades(j).m_iStart),fMax],'facecolor',[0.5 0.5 0.5]);
%             end;
%    
%       h3=plot([fFixationOnsetPlexon-afPlexonTime(1) fFixationOnsetPlexon-afPlexonTime(1)],[fMin fMax],'k','Linewidth',2);
%         h4=plot([fCueOnsetPlexon-afPlexonTime(1) fCueOnsetPlexon-afPlexonTime(1)],[fMin fMax],'r','Linewidth',2);
%         h5=plot([fChoiceOnsetTSPlexon-afPlexonTime(1) fChoiceOnsetTSPlexon-afPlexonTime(1)],[fMin fMax],'g','Linewidth',2);
%          h7 = plot(ones(1,2)*(fConstantFixationOnsetPlexonTS-afPlexonTime(1)),[fMin fMax],'k--','Linewidth',2);
%         h1=plot(afPlexonTime-afPlexonTime(1),afDistFromFixationSpot,'b','linewidth',2);
%         h2=plot(afPlexonTime-afPlexonTime(1),afDistFromTarget,'m','linewidth',2);
%        h6=plot([fSaccadeTSPlexon-afPlexonTime(1) fSaccadeTSPlexon-afPlexonTime(1)],[fMin fMax],'c','Linewidth',2);
%         legend([h1;h2;h3;h4;h5;h6;h7],'Dist To Fixation','Dist To Target','Fixation Cue Onset','Target Flash Onset','Go Signal','Saccade','Monkey is fixating onset');
%         set(gca,'xtick',0:0.1:(afPlexonTime(end)-afPlexonTime(1)));
%         set(gca,'ylim',[0 300]);
%         xlabel('Time (sec)');
%         ylabel('Pixels');
%         title(acTrials{iTrialIndex}.m_strctTrialOutcome.m_strResult);

   end
end
return;
