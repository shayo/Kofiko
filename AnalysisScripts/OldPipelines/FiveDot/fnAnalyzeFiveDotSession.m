function [fGainX, fGainY, fCenterX, fCenterY] = fnAnalyzeFiveDotSession(strctKofiko, strctPlexon, strctSession)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% This script analyzes a five dot session and spits out the average gains
% and offsets that one needs to convert a raw eye signal to eye in screen
% coordinates.
% The conversion is using a simple linear model, i.e. 
% EyeInScreenPos = (EyeRaw-Offset)*Gain 
% The offset and gain are set such that [0,0] is in the screen's center.
%
%


% First, make sure we are analyzing a five dot session.
global g_bVERBOSE
aiScreenCenter = strctKofiko.g_strctStimulusServer.m_aiScreenSize(3:4)/2;
strCalib = 'Five Dot Eye Calibration';
iFiveDotParadigm = -1;
for j=1:length(strctKofiko.g_astrctAllParadigms)
    if strcmp(strctKofiko.g_astrctAllParadigms{j}.m_strName,strCalib)
        iFiveDotParadigm=j;
        break;
    end;
end;
assert(iFiveDotParadigm~=-1);

% First, find which plexon "frame" we need to analyze. 
% A plexon frames is just one of the recorded interval (unpaused->pause)



iSelectedFrame = find(strctPlexon.m_strctEyeX.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');


afPlexonFrameTime = strctPlexon.m_strctEyeX.m_afTimeStamp0(iSelectedFrame):1/strctPlexon.m_strctEyeX.m_fFreq:...
strctPlexon.m_strctEyeX.m_afTimeStamp0(iSelectedFrame)+1/strctPlexon.m_strctEyeX.m_fFreq*...
strctPlexon.m_strctEyeX.m_aiNumSamplesInFragment(iSelectedFrame);

if g_bVERBOSE
    aiInterval = strctPlexon.m_strctEyeX.m_aiStart(iSelectedFrame):strctPlexon.m_strctEyeX.m_aiEnd(iSelectedFrame);
    figure(1);
    clf;
    subplot(2,1,1);
    hold on;
    plot(afPlexonFrameTime,strctPlexon.m_strctEyeX.m_afData(aiInterval));
    plot(ones(1,2)*strctSession.m_fPlexonStartTS, [-2000 2000],'g');
    plot(ones(1,2)*strctSession.m_fPlexonEndTS, [-2000 2000],'g');
    title('Raw Horizontal');
    subplot(2,1,2);
    hold on;
    plot(afPlexonFrameTime,strctPlexon.m_strctEyeY.m_afData(aiInterval));
    plot(ones(1,2)*strctSession.m_fPlexonStartTS, [-2000 2000],'g');
    plot(ones(1,2)*strctSession.m_fPlexonEndTS, [-2000 2000],'g');
    title('Raw Vertical');
end;

% Extract the fixation spot position from Kofiko data structure
F = strctKofiko.g_astrctAllParadigms{iFiveDotParadigm}.m_strctStimulusParams.FixationSpotPix;

abInSession = F.TimeStamp >= strctSession.m_fKofikoStartTS & F.TimeStamp <= strctSession.m_fKofikoEndTS;
afFixationSpotTS_Kofiko = F.TimeStamp(abInSession);
apt2iFixationSpot = squeeze(F.Buffer(:,:,abInSession)); 
% apt2iFixationSpot now holds the fixation spot position, and is timesamped
% (afFixationSpotTS_Kofiko)


% Convert kofiko to plexon timestamp
% afTimeRelative = afFixationSpotTS_Kofiko - strctSession.m_fKofikoStartTS;
% afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%     afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%     strctSession.m_afKofikoTStoPlexonTS(1);

afKofikoInPlexTime = fnKofikoTimeToPlexonTime(strctSession,afFixationSpotTS_Kofiko);
% Estimate center 
aiCenterSpotInd = find(apt2iFixationSpot(1,:) == aiScreenCenter(1) & apt2iFixationSpot(2,:) == aiScreenCenter(2));
iNumIntervalsEyeCenter = length(aiCenterSpotInd);
afXValues = zeros(1,iNumIntervalsEyeCenter);
afYValues = zeros(1,iNumIntervalsEyeCenter);
for k=1:iNumIntervalsEyeCenter
    aiInd = find(afPlexonFrameTime >= afKofikoInPlexTime(aiCenterSpotInd(k)) & ...
         afPlexonFrameTime <= afKofikoInPlexTime(aiCenterSpotInd(k)+1));
    afXValues(k) = median(strctPlexon.m_strctEyeX.m_afData(aiInd));
    afYValues(k) = median(strctPlexon.m_strctEyeY.m_afData(aiInd));    
end;
fCenterX = median(afXValues);
fCenterY = median(afYValues);
fprintf('X Mean %8.2f Std %.2f\n',fCenterX, std(afXValues));
fprintf('Y Mean %8.2f Std %.2f\n',fCenterY, std(afYValues));

% Estimate gain
fPeripheryDistPix = 50;
aiPeripherySpotInd = find( (apt2iFixationSpot(1,1:end-1) - aiScreenCenter(1)).^2 + ...
                        (apt2iFixationSpot(2,1:end-1) - aiScreenCenter(2)).^2 > fPeripheryDistPix);
% Take only intervals that are long enough...
fFixationLengthSec = 1;
aiLongInd = aiPeripherySpotInd(afKofikoInPlexTime(aiPeripherySpotInd+1)-afKofikoInPlexTime(aiPeripherySpotInd) > fFixationLengthSec);
iNumIntervalsEyePeriphery = length(aiLongInd);

afXValues = zeros(1,iNumIntervalsEyePeriphery);
afYValues = zeros(1,iNumIntervalsEyePeriphery);
apt2fSelectedPeripheryFixationSpots = apt2iFixationSpot(:,aiLongInd);
for k=1:iNumIntervalsEyePeriphery
    aiInd = find(afPlexonFrameTime >= afKofikoInPlexTime(aiLongInd(k)) & ...
         afPlexonFrameTime <= afKofikoInPlexTime(aiLongInd(k)+1));
    afXValues(k) = median(strctPlexon.m_strctEyeX.m_afData(aiInd));
    afYValues(k) = median(strctPlexon.m_strctEyeY.m_afData(aiInd)); 
end;
% estimate gain
afGainX = zeros(1,iNumIntervalsEyePeriphery);
afGainY = zeros(1,iNumIntervalsEyePeriphery);

for j=1:iNumIntervalsEyePeriphery
    afGainX(j) = (apt2fSelectedPeripheryFixationSpots(1,j)-aiScreenCenter(1))/(afXValues(j) - fCenterX);
    afGainY(j) = (apt2fSelectedPeripheryFixationSpots(2,j)-aiScreenCenter(2))/(afYValues(2) - fCenterY);
end;
fGainX = median(afGainX);
fGainY = median(afGainY);
fprintf('Gain X  %8.2f Std %.2f \n',fGainX,std(afGainX));
fprintf('Gain Y  %8.2f Std %.2f \n',fGainY,std(afGainY));

return;


%% This code demonstrate how the eye tracking data has almost perfect
%% alignment between plexon and kofiko
% Compare raw eye signal acquired by Kofiko and by plexon
iSelectedSession = 1;

aiInd = 1:strctKofiko.g_strctEyeCalib.EyeRaw.BufferIdx;
iStart = find(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp(aiInd) >= strctSession.m_fKofikoStartTS,1,'first');
iEnd = find(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp(aiInd) <= strctSession.m_fKofikoEndTS,1,'last');
a2fEyeRawKofiko = squeeze(strctKofiko.g_strctEyeCalib.EyeRaw.Buffer(:,:,iStart:iEnd));
afKofikoTS = strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp(iStart:iEnd);

% afTimeRelative = afKofikoTS - strctSession.m_fKofikoStartTS;
% afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%     afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%     strctSession.m_afKofikoTStoPlexonTS(1);
% 

afKofikoInPlexTime = fnKofikoTimeToPlexonTime(strctSession,afKofikoTS);

% Now plexon...
% Ts(k) = TS0 + (k-1)/N * 1/Freq 
% so... 
% Start_Index  = (Start_Time - TS0) * Freq * N + 1

aiInd = strctPlexon.m_strctEyeX.m_aiStart(iSelectedSession):strctPlexon.m_strctEyeX.m_aiEnd(iSelectedSession);

afPlexonFrameTime = strctPlexon.m_strctEyeX.m_afTimeStamp0(iSelectedSession):1/strctPlexon.m_strctEyeX.m_fFreq:...
strctPlexon.m_strctEyeX.m_afTimeStamp0(iSelectedSession)+1/strctPlexon.m_strctEyeX.m_fFreq*...
strctPlexon.m_strctEyeX.m_aiNumSamplesInFragment(iSelectedSession);

a2fEyeRawPlexon = [strctPlexon.m_strctEyeX.m_afData(aiInd),strctPlexon.m_strctEyeY.m_afData(aiInd)];

figure(1);
clf; hold on;
plot(afKofikoInPlexTime,a2fEyeRawKofiko(1,:)-2048,'b.');
%plot(afKofikoInPlexTime,a2fEyeRawKofiko(2,:)-2048,'r');
hold on;
plot(afPlexonFrameTime,a2fEyeRawPlexon(:,1),'c');
%plot(afPlexonFrameTime,a2fEyeRawPlexon(:,2),'y');
legend('Kofiko','Kofiko','Plex','Plex');

