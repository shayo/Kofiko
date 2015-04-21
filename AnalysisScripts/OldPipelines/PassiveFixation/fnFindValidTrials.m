function strctValidTrials = fnFindValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'m_strctStimulusParams')
    
    strctValidTrials = fnOldStyleValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis);
else
   
    strctValidTrials = fnNewStyleValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis);
        
end

function     strctValidTrials = fnNewStyleValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis)



% Now we know what was presented and at what time. 
% We can now extract eye position information and see whether the monkey
% actually looked inside the gaze rect
% For that we need several variables:
% 1. Eye Position in pixel coordinates
% 2. Fixation spot position in pixel coordinates
% 3. Gaze rect size (in pixels)

% Some of the data lies in Plexon and some in Kofiko. 
% We align everything to plexon time frame:
fSamplingFreq = strctPlexon.m_strctEyeX.m_fFreq;
iSelectedFrame = find(strctPlexon.m_strctEyeY.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
afPlexonTime = strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame):1/fSamplingFreq:strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)+...
    (strctPlexon.m_strctEyeY.m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq;


% 1. Eye position in pixel coordinates.
% Eye position is recorded by plexon in mV. This needs to be converted to
% pixel coordinates using the information stored in Kofiko data structure. 

% 1.1 Raw eye signal from Plexon:
iStartIndex = strctPlexon.m_strctEyeY.m_aiStart(iSelectedFrame);
iEndIndex = strctPlexon.m_strctEyeY.m_aiEnd(iSelectedFrame);
afEyeXraw =  strctPlexon.m_strctEyeX.m_afData(iStartIndex:iEndIndex);
afEyeYraw =  strctPlexon.m_strctEyeY.m_afData(iStartIndex:iEndIndex);

% Notice, Raw eye signal can also be obtained from Kofiko:
% EyeRaw = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.EyeRaw, afPlexonTime, strctSession);
% However, plexon DAQ and Kofiko DAQ sample values a bit differently.
% Raw Eye signal (represented in kofiko) - 2048 = Raw eye signal (represented in plexon)

% 1.2 Gain, Offset, Fixation Spot and Rect, all obtained from Kofiko and
% aligned to Plexon time frame:
apt2fFixationSpot = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix, afPlexonTime, strctSession);
afStimulusSizePix = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix, afPlexonTime, strctSession);
afGazeBoxPix = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.GazeBoxPix, afPlexonTime, strctSession);
afOffsetX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterX, afPlexonTime, strctSession);
afOffsetY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterY, afPlexonTime, strctSession);
afGainX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainX, afPlexonTime, strctSession);
afGainY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainY, afPlexonTime, strctSession);

% The way to convert Raw Eye signal from plexon to screen coordinates is:
afEyeXpix = (afEyeXraw+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (afEyeYraw+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;


clear afOffsetX  afOffsetY  afGainX  afGainY afEyeXraw afEyeYraw
 
% Now, Test whether it was inside the rect box or not:
%afStimulusSizePix

abInsideGazeRect = afEyeXpix >= (apt2fFixationSpot(:,1) -  afGazeBoxPix) & afEyeXpix <= (apt2fFixationSpot(:,1) +  afGazeBoxPix) & ...
                   afEyeYpix >= (apt2fFixationSpot(:,2) -  afGazeBoxPix) & afEyeYpix <= (apt2fFixationSpot(:,2) +  afGazeBoxPix);

abInsideStimRect = afEyeXpix >= (apt2fFixationSpot(:,1) -  afStimulusSizePix) & afEyeXpix <= (apt2fFixationSpot(:,1) +  afStimulusSizePix) & ...
                   afEyeYpix >= (apt2fFixationSpot(:,2) -  afStimulusSizePix) & afEyeYpix <= (apt2fFixationSpot(:,2) +  afStimulusSizePix);
               
afDistToFixationSpot = sqrt( (afEyeXpix- apt2fFixationSpot(:,1)          ).^2 +  (afEyeYpix- apt2fFixationSpot(:,2)          ).^2 );


% Now, find invalid trials:
iNumTrials = length(aiStimulusIndex);
abValidTrials = zeros(1, iNumTrials) > 0;
afEyeDistanceFromFixationSpotMedian = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMin = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMax = zeros(1,iNumTrials);
afAvgStimulusSize = zeros(1,iNumTrials);
afFixationPerc = zeros(1,iNumTrials);
warning off
for iTrialIter=1:iNumTrials

    %    iStartIndex = find(afPlexonTime >= afModifiedStimulusON_TS_Plexon(iTrialIter),1,'first');
    %    iEndIndex = find(afPlexonTime <= afModifiedStimulusOFF_TS_Plexon(iTrialIter),1,'last');
    % Or, faster, without the search :
    iStartIndex = 1 + floor((afModifiedStimulusON_TS_Plexon(iTrialIter) - strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)) * fSamplingFreq);
    iEndIndex =min(size(abInsideGazeRect,1),  1 + ceil((afModifiedStimulusOFF_TS_Plexon(iTrialIter) - strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)) * fSamplingFreq));

    
    
    
    afDistX = afEyeXpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,1);
    afDistY = afEyeYpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,2);
    afDist = sqrt(afDistX.^2+afDistY.^2);
    if isempty(afDist)
        afEyeDistanceFromFixationSpotMax(iTrialIter)= NaN;
        afEyeDistanceFromFixationSpotMedian(iTrialIter)= NaN;
        afEyeDistanceFromFixationSpotMin(iTrialIter)= NaN;
    else
        afEyeDistanceFromFixationSpotMax(iTrialIter)= max(afDist);
        afEyeDistanceFromFixationSpotMedian(iTrialIter)= median(afDist);
        afEyeDistanceFromFixationSpotMin(iTrialIter)= min(afDist);
    end
    
    if isempty(strctSpecialAnalysis) || ~isfield(strctSpecialAnalysis,'m_strValidTrialMethod')
        
        fFixationPerc = sum(abInsideGazeRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
        afFixationPerc(iTrialIter) = fFixationPerc;
        
        abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
    else
        switch lower(strctSpecialAnalysis.m_strValidTrialMethod)
            
            case 'insidegazerect'
                fFixationPerc = sum(abInsideGazeRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
                afFixationPerc(iTrialIter) = fFixationPerc;
                abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
            case 'insidestimulus'
                fFixationPerc = sum(abInsideStimRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
                afFixationPerc(iTrialIter) = fFixationPerc;
                abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
            case 'fixeddisttofixationspot'
                abValidTrials(iTrialIter) = all( afDistToFixationSpot(iStartIndex:iEndIndex) <= strctSpecialAnalysis.m_fValidTrialDist);
                afFixationPerc(iTrialIter) = double(abValidTrials(iTrialIter)) * 100;
                
        end
    end
        
    
    
    
    afAvgStimulusSize(iTrialIter) = mean(afStimulusSizePix(iStartIndex:iEndIndex));
end
warning on
strctValidTrials.m_fFixationPercThreshold = fFixationPercThreshold;
strctValidTrials.m_abValidTrials = abValidTrials;
strctValidTrials.m_afEyeDistanceFromFixationSpotMedian = afEyeDistanceFromFixationSpotMedian;
strctValidTrials.m_afEyeDistanceFromFixationSpotMin = afEyeDistanceFromFixationSpotMin;
strctValidTrials.m_afEyeDistanceFromFixationSpotMax = afEyeDistanceFromFixationSpotMax;
strctValidTrials.m_afAvgStimulusSize = afAvgStimulusSize;
strctValidTrials.m_afFixationPerc = afFixationPerc;


if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'DrawAttentionEvents')
   assert( sum(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp==0) == sum(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp==1))
   % Discard any trials that occured next to a draw attention event.
   aiStartIndices = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.Buffer == 1);
   aiEndIndices = aiStartIndices+1;
   
   afStart_DrawAttention_TS_Kofiko = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.DrawAttentionEvents.TimeStamp(aiStartIndices);
      afImageON_TS_Kofiko = fnPlexonTimeToKofikoTime(strctSession, afModifiedStimulusON_TS_Plexon);
   afImageOFF_TS_Kofiko = fnPlexonTimeToKofikoTime(strctSession, afModifiedStimulusOFF_TS_Plexon);

   aiAttentionEvents = find(afStart_DrawAttention_TS_Kofiko >=afImageON_TS_Kofiko(1) & afStart_DrawAttention_TS_Kofiko<=afImageOFF_TS_Kofiko(end));
   
   
   if ~isempty(aiAttentionEvents)
       fnWorkerLog('Several trials were dropped because of a draw attention event');
       % Kill before, current and next trials that are close to a draw
       % attention event.
       iNumTrials = length(afImageON_TS_Kofiko);
       for k=1:length(aiAttentionEvents)
          % Find nearest trial
          [fDummy, iTrialIndex]=min( abs(afImageON_TS_Kofiko - afStart_DrawAttention_TS_Kofiko(aiAttentionEvents(k))));
          strctValidTrials.m_abValidTrials(max(1,iTrialIndex-1):min(iNumTrials,iTrialIndex+1)) = false;
       end
   end
   
   
end
    


return;

 

function strctValidTrials = fnOldStyleValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon,strctSpecialAnalysis)


% Now we know what was presented and at what time. 
% We can now extract eye position information and see whether the monkey
% actually looked inside the gaze rect
% For that we need several variables:
% 1. Eye Position in pixel coordinates
% 2. Fixation spot position in pixel coordinates
% 3. Gaze rect size (in pixels)

% Some of the data lies in Plexon and some in Kofiko. 
% We align everything to plexon time frame:
fSamplingFreq = strctPlexon.m_strctEyeX.m_fFreq;
iSelectedFrame = find(strctPlexon.m_strctEyeY.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
if isempty(iSelectedFrame)
    iSelectedFrame = 1;
end;
afPlexonTime = strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame):1/fSamplingFreq:strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)+...
    (strctPlexon.m_strctEyeY.m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq;


% 1. Eye position in pixel coordinates.
% Eye position is recorded by plexon in mV. This needs to be converted to
% pixel coordinates using the information stored in Kofiko data structure. 

% 1.1 Raw eye signal from Plexon:
iStartIndex = strctPlexon.m_strctEyeY.m_aiStart(iSelectedFrame);
iEndIndex = strctPlexon.m_strctEyeY.m_aiEnd(iSelectedFrame);
afEyeXraw =  strctPlexon.m_strctEyeX.m_afData(iStartIndex:iEndIndex);
afEyeYraw =  strctPlexon.m_strctEyeY.m_afData(iStartIndex:iEndIndex);

% Notice, Raw eye signal can also be obtained from Kofiko:
% EyeRaw = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.EyeRaw, afPlexonTime, strctSession);
% However, plexon DAQ and Kofiko DAQ sample values a bit differently.
% Raw Eye signal (represented in kofiko) - 2048 = Raw eye signal (represented in plexon)

% 1.2 Gain, Offset, Fixation Spot and Rect, all obtained from Kofiko and
% aligned to Plexon time frame:
apt2fFixationSpot = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.FixationSpotPix, afPlexonTime, strctSession);
afStimulusSizePix = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix, afPlexonTime, strctSession);
afGazeBoxPix = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.GazeBoxPix, afPlexonTime, strctSession);
afOffsetX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterX, afPlexonTime, strctSession);
afOffsetY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterY, afPlexonTime, strctSession);
afGainX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainX, afPlexonTime, strctSession);
afGainY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainY, afPlexonTime, strctSession);

% The way to convert Raw Eye signal from plexon to screen coordinates is:
afEyeXpix = (afEyeXraw+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (afEyeYraw+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;


clear afOffsetX  afOffsetY  afGainX  afGainY afEyeXraw afEyeYraw
 
% Now, Test whether it was inside the rect box or not:

abInsideRect = afEyeXpix >= (apt2fFixationSpot(:,1) -  max(afStimulusSizePix,afGazeBoxPix) ) & afEyeXpix <= (apt2fFixationSpot(:,1) +  max(afStimulusSizePix,afGazeBoxPix)) & ...
               afEyeYpix >= (apt2fFixationSpot(:,2) -  max(afStimulusSizePix,afGazeBoxPix)) & afEyeYpix <= (apt2fFixationSpot(:,2) +  max(afStimulusSizePix,afGazeBoxPix));

% abInsideRect = afEyeXpix >= (apt2fFixationSpot(:,1) -  afStimulusBoxPix) & afEyeXpix <= (apt2fFixationSpot(:,1) +  afStimulusBoxPix) & ...
%                afEyeYpix >= (apt2fFixationSpot(:,2) -  afStimulusBoxPix) & afEyeYpix <= (apt2fFixationSpot(:,2) +  afStimulusBoxPix);


% Now, find invalid trials:
iNumTrials = length(aiStimulusIndex);
abValidTrials = zeros(1, iNumTrials) > 0;
afEyeDistanceFromFixationSpotMedian = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMin = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMax = zeros(1,iNumTrials);
afAvgStimulusSize = zeros(1,iNumTrials);
afFixationPerc = zeros(1,iNumTrials);
warning off
for iTrialIter=1:iNumTrials

    %    iStartIndex = find(afPlexonTime >= afModifiedStimulusON_TS_Plexon(iTrialIter),1,'first');
    %    iEndIndex = find(afPlexonTime <= afModifiedStimulusOFF_TS_Plexon(iTrialIter),1,'last');
    % Or, faster, without the search :
    iStartIndex = 1 + floor((afModifiedStimulusON_TS_Plexon(iTrialIter) - strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)) * fSamplingFreq);
    iEndIndex =min(size(abInsideRect,1),  1 + ceil((afModifiedStimulusOFF_TS_Plexon(iTrialIter) - strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)) * fSamplingFreq));

    fFixationPerc = sum(abInsideRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
    afFixationPerc(iTrialIter) = fFixationPerc;
    abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
    afDistX = afEyeXpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,1);
    afDistY = afEyeYpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,2);
    afDist = sqrt(afDistX.^2+afDistY.^2);
    if isempty(afDist)
        afEyeDistanceFromFixationSpotMax(iTrialIter)= NaN;
        afEyeDistanceFromFixationSpotMedian(iTrialIter)= NaN;
        afEyeDistanceFromFixationSpotMin(iTrialIter)= NaN;
    else
        afEyeDistanceFromFixationSpotMax(iTrialIter)= max(afDist);
        afEyeDistanceFromFixationSpotMedian(iTrialIter)= median(afDist);
        afEyeDistanceFromFixationSpotMin(iTrialIter)= min(afDist);
    end
    afAvgStimulusSize(iTrialIter) = mean(afStimulusSizePix(iStartIndex:iEndIndex));
end
warning on
strctValidTrials.m_fFixationPercThreshold = fFixationPercThreshold;
strctValidTrials.m_abValidTrials = abValidTrials;
strctValidTrials.m_afEyeDistanceFromFixationSpotMedian = afEyeDistanceFromFixationSpotMedian;
strctValidTrials.m_afEyeDistanceFromFixationSpotMin = afEyeDistanceFromFixationSpotMin;
strctValidTrials.m_afEyeDistanceFromFixationSpotMax = afEyeDistanceFromFixationSpotMax;
strctValidTrials.m_afAvgStimulusSize = afAvgStimulusSize;
strctValidTrials.m_afFixationPerc = afFixationPerc;


return;