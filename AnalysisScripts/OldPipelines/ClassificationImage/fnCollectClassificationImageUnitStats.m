function acUnitsStat = fnCollectClassificationImageUnitStats(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig)
%strctStatParams
% Computes various statistics about the recorded units in a given recorded session
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

if isempty(strctSession)
    fnWorkerLog('Behavioral data analysis for classification image during the ENTIRE experiment is not yet implemented.');
    acUnitsStat = [];    
    return;
end;

iParadigmIndex = -1;
for j=1:length(strctKofiko.g_astrctAllParadigms)
    if strcmp(strctKofiko.g_astrctAllParadigms{j}.m_strName,'Classification Image')
        iParadigmIndex=j;
        break;
    end;
end;
assert(iParadigmIndex~=-1);

% Assume a single mode per recorded session.....

if ~isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex},'CurrParadigmMode')
    iParadigmMode = 1;
else
    
aiParadigmModes = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.CurrParadigmMode.TimeStamp,...
            strctKofiko.g_astrctAllParadigms{iParadigmIndex}.CurrParadigmMode.Buffer,strctSession.m_fKofikoStartTS:strctSession.m_fKofikoEndTS);
[aiModes,aiCount]=unique(aiParadigmModes);
if length(aiModes) > 1
    [fDummy, iParadigmMode] = max(aiCount);
else
    iParadigmMode = aiModes(1);
end
end

switch iParadigmMode
    case 1
        % Mini-FOB session. Can be analyzed like a passive fixation
        % session.
        acUnitsStat = fnCollectPassiveFixationUnitStatsAux(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex);
        return;
    case 2 
        % Estimate Neurometric curve
        acUnitsStat = fnBuildNeurometricCurve(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex);
        
    case 3
        % Compute classification image
        acUnitsStat = fnComputeClassificationImage(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex);
      
end

function acUnitsStat = fnComputeClassificationImage(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

% Find accurate stimulus onset using photodiode data
[aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
    fnGetAccurateStimulusTSusingPhotodiode(strctKofiko, strctPlexon, strctSession,iParadigmIndex);


% Find valid trials, in which monkey fixated at the fixation point
strctValidTrials = fnFindValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,...
    strctConfig.m_strctParams.m_fFixationPercThreshold,...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon);
abValidTrials = strctValidTrials.m_abValidTrials;

[strctStimulusParams,strRandFile,afRecordingRange] = ...
    fnGetStimulusParametersForValidTrials(strctKofiko, strctSession,iParadigmIndex,abValidTrials);

aiStimulusIndexValid = aiStimulusIndex(abValidTrials);
iNumUnits = length(strctPlexon.m_astrctUnits);

aiPeriStimulusRangeMS = strctConfig.m_strctParams.m_iBeforeMS:strctConfig.m_strctParams.m_iAfterMS;
iStartAvg = find(aiPeriStimulusRangeMS >= strctConfig.m_strctParams.m_iStartAvgMS,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS >= strctConfig.m_strctParams.m_iEndAvgMS,1,'first');

[strPath,strFile,strExt]=fileparts(strRandFile);

strctTmp = load([strctConfig.m_strctParams.m_strRandFilesFolder,strFile,'.mat']);

%acList = fnReadImageList('D:\Data\Doris\Stimuli\ClassificationImage\faces_objects.txt');
warning off
acUnitsStat = cell(1,iNumUnits);
for iUnitIter = 1:iNumUnits

    [a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctPlexon.m_astrctUnits(iUnitIter), ...
        afModifiedStimulusON_TS_Plexon, strctConfig.m_strctParams.m_iBeforeMS,...
        strctConfig.m_strctParams.m_iAfterMS);

    a2bRaster_Valid = a2bRaster(abValidTrials,:);

    iFaceImage = unique(aiStimulusIndexValid(aiStimulusIndexValid ~= strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex));
    
    [strDummy,strFile,strExt]=fileparts(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_acFileNames{iFaceImage});
    a2iImage = imread([strctConfig.m_strctParams.m_strRandFilesFolder,strFile,strExt]);
    
    
    aiIndFaces = find(aiStimulusIndexValid ~= strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex);
    aiIndNonFaces = find(aiStimulusIndexValid == strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex);

    afAllRes = sum(a2bRaster_Valid(:,iStartAvg:iEndAvg),2);

    a2fResponseFace = a2bRaster_Valid(aiIndFaces,:);
    a2fResponseNonFace = a2bRaster_Valid(aiIndNonFaces,:);
    afResFace = sum(a2fResponseFace(:,iStartAvg:iEndAvg),2);
    afResNonFace = sum(a2fResponseNonFace(:,iStartAvg:iEndAvg),2);


    iMin = min(min(afResFace),min(afResNonFace));
    iMax = max(max(afResFace),max(afResNonFace));

    aiInterval = iMin:iMax;
    afHistFace = hist(afResFace,aiInterval);
    afHistNonFace = hist(afResNonFace,aiInterval);    
    
    if 0
    figure(1);
    clf;
    bar(aiInterval,[afHistFace', afHistNonFace'])
    hold on;
    plot(aiInterval,afHistFace,'b');
    plot(aiInterval,afHistNonFace,'r');
    legend('Face','Non Face');
    end
    
    afRatio = afHistFace ./ afHistNonFace ;
    iThresIndex = find(afRatio  >= 0.5 & ~isnan(afRatio ) & ~isinf(afRatio ),1,'first');
    iThres = aiInterval(iThresIndex);
    % iThres = find(afHistPos > afHistNeg,1,'first');
     if ~isempty(iThres)
         
         aiPos = find(afAllRes>=iThres);
         aiNeg = find(afAllRes<iThres);

%          abNeg = zeros(length(afAllRes),1);
%          abPos = zeros(length(afAllRes),1);
%          abNeg(aiNeg) = true;
%          abPos(aiPos) = true;
%          abTarget = aiStimulusIndexValid ~= strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex;
%          abNoTarget = aiStimulusIndexValid == strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex;         
% 
%          figure(1);
%          clf;
%          hist(afAllRes(abNoTarget & abPos))
         
         
         aiNoiseIndex= strctStimulusParams.m_aiNoiseIndex;

         a2fPos = mean(strctTmp.a2fRand(:,:,aiNoiseIndex(aiPos)),3);
         a2fNeg = mean(strctTmp.a2fRand(:,:,aiNoiseIndex(aiNeg)),3);

         
         a2fPpos = zeros(100,100);
         a2fPneg = zeros(100,100);
         for i=1:100
             for j=1:100
                 [h1,a2fPpos(i,j)]=ttest(squeeze(strctTmp.a2fRand(i,j,aiNoiseIndex(aiPos))));
                 [h2,a2fPneg(i,j)]=ttest(squeeze(strctTmp.a2fRand(i,j,aiNoiseIndex(aiNeg))));
             end;
         end;

     else
         a2fPos = [];
         a2fNeg = [];
         a2fPpos = [];
         a2fPneg = [];
     end

       
%      T =  conv2(a2fPos, fspecial('gaussian',[7 7],3),'same');
%      afDot = zeros(1,N);
%      for k=1:N
%          fAlpha =strctStimulusParams.m_afNoiseLevel(k)/100;
%          a2fNoise = strctTmp.a2fRand(:,:,strctStimulusParams.m_aiNoiseIndex(k) );
%          a2fNoise = a2fNoise * 128/3.9 + 128;
%          a2fImage = double(a2iImage);
%          I = (min(255,max(0,(1-fAlpha) * a2fImage + (fAlpha) * a2fNoise)));
%          I = (I - 128) / 128;
%          afDot(k) = sum(sum(double(I) .* T));
%      end
%      corr(afDot', afAllRes)


% 
%     abResponse = afAllRes >= iThres;
%     abGroundTruth = aiStimulusIndexValid ~= strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex;
%     
%     fTPRate = sum(abResponse == 1 & abGroundTruth == 1) / sum(abGroundTruth == 1) * 100;
%     fTNRate = sum(abResponse == 0 & abGroundTruth == 0) / sum(abGroundTruth == 0) * 100;
%     fFPRate = sum(abResponse == 1 & abGroundTruth == 0) / sum(abGroundTruth == 0) * 100;
%     fFNRate = sum(abResponse == 0 & abGroundTruth == 1) / sum(abGroundTruth == 1) * 100;
    if isfield(strctKofiko.g_strctAppConfig,'m_strTimeDate')
        strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
   else
        strctUnit.m_strRecordedTimeDate = 'Unknown';
   end;

    strctUnit.m_iRecordedSession = iSessionIter;
    strctUnit.m_iChannel = strctPlexon.m_astrctUnits(iUnitIter).m_iChannel;
    strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iUnitIter).m_iUnit;
    strctUnit.m_fDurationMin = (strctSession.m_fKofikoEndTS-strctSession.m_fKofikoStartTS)/60;
    strctUnit.m_strParadigm = 'Classification Image';
    strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
    strctUnit.m_strParadigmDesc = 'Classification Image';
    strctUnit.m_strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;
    strctUnit.m_a2bRaster_Valid = a2bRaster_Valid;
    strctUnit.m_aiIndFaces = aiIndFaces;
    strctUnit.m_aiIndNonFaces = aiIndNonFaces;
    strctUnit.m_aiPeriStimulusRangeMS = aiPeriStimulusRangeMS;
    strctUnit.m_strctValidTrials = strctValidTrials;
    strctUnit.m_strctConstParams = strctConfig;
    strctUnit.m_afRecordingRange = afRecordingRange;
    strctUnit.m_afHistFace = afHistFace;
    strctUnit.m_afHistNonFace = afHistNonFace;
    strctUnit.m_aiHistInterval = aiInterval;
    strctUnit.m_a2fPos = a2fPos;
    strctUnit.m_a2fNeg = a2fNeg;
    strctUnit.m_afSpikeForm = mean(a2fAvgSpikeForm,1);
    
    strctUnit.m_strRandFile = strFile;
    strctUnit.m_a2iFaceImage = a2iImage;
    strctUnit.m_a2fPosPvalue = a2fPpos;
    strctUnit.m_a2fNegPvalue = a2fPneg;

    acUnitsStat{iUnitIter} = strctUnit;
end
warning on
return;

function acUnitsStat = fnBuildNeurometricCurve(strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

% Find accurate stimulus onset using photodiode data
[aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = ...
    fnGetAccurateStimulusTSusingPhotodiode(strctKofiko, strctPlexon, strctSession,iParadigmIndex);


% Find valid trials, in which monkey fixated at the fixation point
if ~isfield(strctConfig,'m_fFixationPercThreshold')
    strctConfig.m_fFixationPercThreshold = 0.95;
end

strctValidTrials = fnFindValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,...
    strctConfig.m_fFixationPercThreshold,...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon);

abValidTrials = strctValidTrials.m_abValidTrials;

[strctStimulusParams, strRandFile, afRecordingRange] = ...
    fnGetStimulusParametersForValidTrials(strctKofiko, strctSession,iParadigmIndex,abValidTrials);
aiStimulusIndexValid = aiStimulusIndex(abValidTrials);
iNumUnits = length(strctPlexon.m_astrctUnits);
afNoiseLevels = unique(strctStimulusParams.m_afNoiseLevel);

aiPeriStimulusRangeMS = strctConfig.m_strctParams.m_iBeforeMS:strctConfig.m_strctParams.m_iAfterMS;
iStartAvg = find(aiPeriStimulusRangeMS >= strctConfig.m_strctParams.m_iStartAvgMS,1,'first');
iEndAvg = find(aiPeriStimulusRangeMS >= strctConfig.m_strctParams.m_iEndAvgMS,1,'first');

acUnitsStat = cell(1,iNumUnits);
warning off
for iUnitIter = 1:iNumUnits

    [a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctPlexon.m_astrctUnits(iUnitIter), ...
        afModifiedStimulusON_TS_Plexon, strctConfig.m_strctParams.m_iBeforeMS,...
        strctConfig.m_strctParams.m_iAfterMS);

    a2bRaster_Valid = a2bRaster(abValidTrials,:);

    
    aiIndFaces = find(aiStimulusIndexValid ~= strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex);
    aiIndNonFaces = find(aiStimulusIndexValid == strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_iNoiseImageIndex);

    afNoiseFaces = strctStimulusParams.m_afNoiseLevel(aiIndFaces);
    afNoiseNonFaces = strctStimulusParams.m_afNoiseLevel(aiIndNonFaces);

    iNumNoiseLevels = length(afNoiseLevels);
    afPerecentCorrect = zeros(1,iNumNoiseLevels);
    afStdPos = zeros(1,iNumNoiseLevels);
    afNumZeroResPos = zeros(1,iNumNoiseLevels);
    afMeanFiringRatePos = zeros(1,iNumNoiseLevels);
    afMeanFiringRateNeg = zeros(1,iNumNoiseLevels);    
    warning off
    for iNoiseIter=1:iNumNoiseLevels
        abSameNoiseLevelFaces = afNoiseFaces == afNoiseLevels(iNoiseIter);
        abSameNoiseLevelNonFaces = afNoiseNonFaces == afNoiseLevels(iNoiseIter);

        a2fResponsePos = a2bRaster_Valid(aiIndFaces(abSameNoiseLevelFaces),:);
        a2fResponseNeg = a2bRaster_Valid(aiIndNonFaces(abSameNoiseLevelNonFaces),:);

        % Test performance in individual trials (!)
        afResPos = 1e3*mean(a2fResponsePos(:,iStartAvg:iEndAvg),2);
        afResNeg = 1e3*mean(a2fResponseNeg(:,iStartAvg:iEndAvg),2);
        afMeanFiringRatePos(iNoiseIter) = mean(afResPos);
        afMeanFiringRateNeg(iNoiseIter) = mean(afResNeg);        
%         figure(1);clf; hold on;
%         [a1,b1]=hist(afResPos);
%         [a2,b2]=hist(afResNeg);
%         bar(b1,a1,'facecolor','b');
%         bar(b2,a2,'facecolor','r');
        

        fDeno = sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);       
        dPrime = abs(mean(afResPos) - mean(afResNeg)) / (fDeno+eps);
        afPerecentCorrect(iNoiseIter) = normcdf(dPrime / sqrt(2)) * 100;
        afStdPos(iNoiseIter) = std(afResPos);
        afNumZeroResPos(iNoiseIter) = sum(afResPos==0)/length(afResPos);
    end
    warning on
    
    if isfield(strctKofiko.g_strctAppConfig,'m_strTimeDate')
        strctUnit.m_strRecordedTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
   else
        strctUnit.m_strRecordedTimeDate = 'Unknown';
   end;

    strctUnit.m_iRecordedSession = iSessionIter;
    strctUnit.m_iChannel = strctPlexon.m_astrctUnits(iUnitIter).m_iChannel;
    strctUnit.m_iUnitID = strctPlexon.m_astrctUnits(iUnitIter).m_iUnit;
    strctUnit.m_fDurationMin = (strctSession.m_fKofikoEndTS-strctSession.m_fKofikoStartTS)/60;
    strctUnit.m_strParadigm = 'Classification Image';
    strctUnit.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
    strctUnit.m_strParadigmDesc = 'Neurometric Curve';
    strctUnit.m_afPerecentCorrect = afPerecentCorrect;
    strctUnit.m_afStdPos = afStdPos;
    strctUnit.m_afNumZeroResPos = afNumZeroResPos;    
    strctUnit.m_afMeanFiringRatePos = afMeanFiringRatePos;
    strctUnit.m_afMeanFiringRateNeg = afMeanFiringRateNeg;
    strctUnit.m_strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;
    strctUnit.m_afNoiseLevels = afNoiseLevels;
    strctUnit.m_afRecordingRange = afRecordingRange;
    strctUnit.m_strctValidTrials = strctValidTrials;
    % Sort Raster...
    [afSortedNoiseFaces,aiSortedFaceInd] = sort(afNoiseFaces);
    [afSortedNoiseNonFaces,aiSortedNonFaceInd] = sort(afNoiseNonFaces);

    strctUnit.m_a2bSortedRaster = [a2bRaster_Valid(aiIndFaces(aiSortedFaceInd),:);...
    a2bRaster_Valid(aiIndNonFaces(aiSortedNonFaceInd),:);];
    strctUnit.m_aiPeriStimulusRangeMS = aiPeriStimulusRangeMS;
    
    acUnitsStat{iUnitIter} = strctUnit;
end
warning on
return;


function strctValidTrials = fnFindValidTrials(strctKofiko, strctPlexon, strctSession,iParadigmIndex,fFixationPercThreshold, ...
    aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon)
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
apt2fFixationSpot = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.FixationSpotPix, afPlexonTime, strctSession);
afGazeBoxPix = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.GazeBoxPix, afPlexonTime, strctSession);
afStimulusSizePix = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix, afPlexonTime, strctSession);
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

%clear afEyeXpix afEyeYpix  apt2fFixationSpot      

% Now, find invalid trials:
iNumTrials = length(aiStimulusIndex);
abValidTrials = zeros(1, iNumTrials) > 0;

afEyeDistanceFromFixationSpotMedian = zeros(1,iNumTrials);
afEyeDistanceFromFixationSpotMin = zeros(1,iNumTrials);
afAvgStimulusSize = zeros(1,iNumTrials);
afFixationPerc = zeros(1,iNumTrials);
for iTrialIter=1:iNumTrials
    %    iStartIndex = find(afPlexonTime >= afModifiedStimulusON_TS_Plexon(iTrialIter),1,'first');
    %    iEndIndex = find(afPlexonTime <= afModifiedStimulusOFF_TS_Plexon(iTrialIter),1,'last');
    % Or, faster, without the search :

    iStartIndex = 1 + floor((afModifiedStimulusON_TS_Plexon(iTrialIter) - strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)) * fSamplingFreq);
    iEndIndex =min(size(abInsideRect,1),  1 + ceil((afModifiedStimulusOFF_TS_Plexon(iTrialIter) - strctPlexon.m_strctEyeY.m_afTimeStamp0(iSelectedFrame)) * fSamplingFreq));

    fFixationPerc = sum(abInsideRect(iStartIndex:iEndIndex)) / (iEndIndex-iStartIndex+1) * 100;
    afFixationPerc(iTrialIter) = fFixationPerc ;
    abValidTrials(iTrialIter) = fFixationPerc > fFixationPercThreshold;
    afDistX = afEyeXpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,1);
    afDistY = afEyeYpix(iStartIndex:iEndIndex)-apt2fFixationSpot(iStartIndex:iEndIndex,2);
    afDist = sqrt(afDistX.^2+afDistY.^2);
    afEyeDistanceFromFixationSpotMedian(iTrialIter)= median(afDist);
    afEyeDistanceFromFixationSpotMin(iTrialIter)= min(afDist);
    afAvgStimulusSize(iTrialIter) = mean(afStimulusSizePix(iStartIndex:iEndIndex));
end

strctValidTrials.m_fFixationPercThreshold = fFixationPercThreshold;
strctValidTrials.m_abValidTrials = abValidTrials;
strctValidTrials.m_afEyeDistanceFromFixationSpotMedian = afEyeDistanceFromFixationSpotMedian;
strctValidTrials.m_afEyeDistanceFromFixationSpotMin = afEyeDistanceFromFixationSpotMin;
strctValidTrials.m_afAvgStimulusSize = afAvgStimulusSize;
strctValidTrials.m_afFixationPerc = afFixationPerc;


return;



function [aiStimulusIndex,afModifiedStimulusON_TS_Plexon,afModifiedStimulusOFF_TS_Plexon] = fnGetAccurateStimulusTSusingPhotodiode(strctKofiko, strctPlexon, strctSession,iParadigmIndex)
% First thing first, identify when stimulus was displayed using the photodiode sensor
S = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrStimulusIndex;
iStart = find(S.TimeStamp >= strctSession.m_fKofikoStartTS,1,'first');
iEnd = find(S.TimeStamp <= strctSession.m_fKofikoEndTS,1,'last');

% These two variables hold the list of stimuli displayed and their Kofiko timestamp
aiStimuli = squeeze(S.Buffer(iStart:iEnd));
afStimuli_TS_Kofiko = S.TimeStamp(iStart:iEnd);

% We can also extract this information from the plexon strobe word data structure
iStart = find(strctPlexon.m_strctStrobeWord.m_afTimestamp >= strctSession.m_fPlexonStartTS,1,'first');
iEnd = find(strctPlexon.m_strctStrobeWord.m_afTimestamp <= strctSession.m_fPlexonEndTS,1,'last');
% This is also represented as:  strctSession.m_aiPlexonStrobeInterval


% These two variables hold the list of stimuli displayed and their Kofiko timestamp
% Assume maximum of 30,000 stimulus types...
aiIndices = find(strctPlexon.m_strctStrobeWord.m_aiWords(iStart:iEnd) < 30000);
aiStimuli_Plexon = strctPlexon.m_strctStrobeWord.m_aiWords(iStart+aiIndices-1);
afStimuli_TS_Plexon = strctPlexon.m_strctStrobeWord.m_afTimestamp(iStart+aiIndices-1);

if length(aiStimuli_Plexon) ~= length(aiStimuli)
   fnWorkerLog('Warning, Plexon and Kofiko do not match!!!');
   fnWorkerLog('Probably just trailing zeros. Trying to crop...');
   iMinLen = min(length(aiStimuli_Plexon), length(aiStimuli));
   
   if (all(aiStimuli(iMinLen+1:end) == 0))
       aiStimuli = aiStimuli(1:iMinLen);
       fnWorkerLog('OK. Fixed that problem.');
   else 
       iStartIndex = find(aiStimuli>0,1,'first');
       if length(aiStimuli(iStartIndex:end)) == length(aiStimuli_Plexon) && all(aiStimuli(iStartIndex:end) == aiStimuli_Plexon)
       aiStimuli = aiStimuli(iStartIndex:end);
       fnWorkerLog('OK. Fixed that problem.');
           
       else
           
           assert(false);
       end
   end
end

assert( all(aiStimuli_Plexon == aiStimuli));

% Now, restrict analysis to the ON events:
aiStimulusIndex = aiStimuli_Plexon(aiStimuli_Plexon>0);
afStimuliON_TS_Plexon = afStimuli_TS_Plexon(aiStimuli_Plexon>0);

% Search for the rise of the photodiode TTL pulse, just after stimulus strobe

iSelectedFrame = find(strctPlexon.m_strctPhotodiode.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');

iStart = strctPlexon.m_strctPhotodiode.m_aiStart(iSelectedFrame);
iEnd = strctPlexon.m_strctPhotodiode.m_aiEnd(iSelectedFrame);

fTTLThreshold = 1000;
[astrctStimulusONIntervals,aiStartIndicesON] = fnGetIntervals(strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) > fTTLThreshold);

if 0
    % This will show stimulus on time, as recv by plexon strobe word, and 
    % the rise of the photo diode (after image was painted on screen)
    afTime = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame):1/strctPlexon.m_strctPhotodiode.m_fFreq:...
        strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame)+(iEnd-iStart) * 1/strctPlexon.m_strctPhotodiode.m_fFreq;
    figure(1);
    clf;
    plot(afStimuliON_TS_Plexon, aiStimulusIndex,'b.');
    hold on;
    plot(afTime, strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) ,'r');
    plot(afTime, strctPlexon.m_strctPhotodiode.m_afData(iStart:iEnd) ,'r.');
    axis([afTime(1) afTime(1)+2 0 2500]);
end

afPhotodiodeON_TS_Plexon = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame) + (aiStartIndicesON-1) / strctPlexon.m_strctPhotodiode.m_fFreq;

if 0
    [C,H]=hist(cat(1,astrctStimulusONIntervals.m_iLength)/strctPlexon.m_strctPhotodiode.m_fFreq*1e3);
    [C(C>0)./sum(C)*100;H(C>0)]
% First row is the percentage of stimulus presentations, second row is timing in ms
end;



% for each stimulus presentation, find the nearest rise of photodiode
% signal:
iNumStimuliDisplayed = length(aiStimulusIndex);
afModifiedStimulusON_TS_Plexon = zeros(1, iNumStimuliDisplayed);
afModifiedStimulusOFF_TS_Plexon = zeros(1, iNumStimuliDisplayed);
for iStimulusIter=1:iNumStimuliDisplayed
    iIndexON = find(afPhotodiodeON_TS_Plexon >= afStimuliON_TS_Plexon(iStimulusIter),1,'first');
    afModifiedStimulusON_TS_Plexon(iStimulusIter) = afPhotodiodeON_TS_Plexon(iIndexON);
    
    % Note, the OFF is probably not accurate because the photodiode
    % amplifiler elongates the TTL pulse by a fixed amount, which depend on
    % the threshold setting. In my rig, the TTL pulse will remain high for
    % ~ 11 ms after photodiode signal goes high. 
    afModifiedStimulusOFF_TS_Plexon(iStimulusIter) = afPhotodiodeON_TS_Plexon(iIndexON) + ...
                                                     astrctStimulusONIntervals(iIndexON).m_iLength / strctPlexon.m_strctPhotodiode.m_fFreq;
end;

%fprintf('Max time to next photodiode TTL (should be quite small) : %.2f\n',max((afModifiedStimulusON_TS_Plexon'-afStimuliON_TS_Plexon)*1e3));
%%% If we ever want to convert a timestamp from Kofiko to plexon, here is
%%% what needs to be done:
if 0
%     afTimeRelative = afStimuli_TS_Kofiko - strctSession.m_fKofikoStartTS;
%     afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%         afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%         strctSession.m_afKofikoTStoPlexonTS(1);
% 
    afTime = strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame):1/strctPlexon.m_strctPhotodiode.m_fFreq:...
        strctPlexon.m_strctPhotodiode.m_afTimeStamp0(iSelectedFrame)+...
        (strctPlexon.m_strctPhotodiode.m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/strctPlexon.m_strctPhotodiode.m_fFreq;
    
    figure(2);
    clf;
    hold on;
    plot(afTime, strctPlexon.m_strctPhotodiode.m_afData(strctPlexon.m_strctPhotodiode.m_aiStart(iSelectedFrame):strctPlexon.m_strctPhotodiode.m_aiEnd(iSelectedFrame)));
    for k=1:length(afStimuli_TS_Plexon)
        plot([afStimuli_TS_Plexon(k),afStimuli_TS_Plexon(k)],[0 1000],'g');
        plot([afKofikoInPlexTime(k), afKofikoInPlexTime(k)],[0 500],'r');
    end;

end;


return;






function Values = fnResampleKofikoToPlexOLD(strctTsVar, afPlexonTime, strctSession)
iStart = find(strctTsVar.TimeStamp <= strctSession.m_fKofikoStartTS,1,'last');

if isempty(iStart)
    % No timestamp information is available for this session. 
    % Value was probably initialized at startup and was not changed throughout the experiment...
      iIndex = find(strctTsVar.TimeStamp  <= strctSession.m_fKofikoStartTS,1,'last');
    iDim = size(strctTsVar.Buffer,2);
    if iDim > 2
        iDim = size(strctTsVar.Buffer,1);
    end;
    Values = zeros( length(afPlexonTime), iDim);
    if iDim == 1
        Values(:) = strctTsVar.Buffer(iIndex);
    else
        for iIter=1:iDim
            Values(:,iIter) = strctTsVar.Buffer(iDim,iIndex);
        end;
    end;
   
else
   iEnd = find(strctTsVar.TimeStamp >= strctSession.m_fKofikoEndTS,1,'first');    
    if isempty(iEnd)
       iEnd = length(strctTsVar.TimeStamp);
    end;
    aiInterval = iStart:iEnd; 
      
    % Convert strctTsVar (kofiko timestamp) to plexon timestamp
    afKofikoInPlexTime = fnKofikoTimeToPlexonTime(strctSession,strctTsVar.TimeStamp(aiInterval));
%     afTimeRelative = strctTsVar.TimeStamp(aiInterval) - strctSession.m_fKofikoStartTS;
%     afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%         afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%         strctSession.m_afKofikoTStoPlexonTS(1);

    iDim = size(strctTsVar.Buffer,1);
    if iDim > 2
        strctTsVar.Buffer= strctTsVar.Buffer';
        iDim = size(strctTsVar.Buffer,1);
    end;
    
    Values = zeros( length(afPlexonTime), iDim);
    for iDimIter=1:iDim
        Values(:,iDimIter) = fnMyInterp1(afKofikoInPlexTime, squeeze(strctTsVar.Buffer(iDimIter,aiInterval)), afPlexonTime);
    end;
end;






return;

function Values = fnResampleKofikoToPlex(strctTsVar, afPlexonTime, strctSession)
try
    iStart = find(strctTsVar.TimeStamp <= strctSession.m_fKofikoStartTS,1,'last');
%find(strctTsVar.TimeStamp  >= strctSession.m_fKofikoStartTS & ...
%     strctTsVar.TimeStamp <= strctSession.m_fKofikoEndTS);
if isempty(iStart)
    % No timestamp information is available for this session. 
    % Value was probably initialized at startup and was not changed throughout the experiment...
      iIndex = find(strctTsVar.TimeStamp  <= strctSession.m_fKofikoStartTS,1,'last');
    iDim = size(strctTsVar.Buffer,2);
    Values = zeros( length(afPlexonTime), iDim);
    for iIter=1:iDim
        Values(:,iIter) = strctTsVar.Buffer(iIndex,iDim);
    end;

else
    iEnd = find(strctTsVar.TimeStamp >= strctSession.m_fKofikoEndTS,1,'first');    
    if isempty(iEnd)
       iEnd = length(strctTsVar.TimeStamp);
    end;
    aiInterval = iStart:iEnd; 
     
    % Convert strctTsVar (kofiko timestamp) to plexon timestamp
        afKofikoInPlexTime = fnKofikoTimeToPlexonTime(strctSession,strctTsVar.TimeStamp(aiInterval));

%     afTimeRelative = strctTsVar.TimeStamp(aiInterval) - strctSession.m_fKofikoStartTS;
%     afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%         afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%         strctSession.m_afKofikoTStoPlexonTS(1);

    iDim = size(strctTsVar.Buffer,2);
    Values = zeros( length(afPlexonTime), iDim);
    for iDimIter=1:iDim
        Values(:,iDimIter) = fnMyInterp1(afKofikoInPlexTime, squeeze(strctTsVar.Buffer(aiInterval,iDimIter)), afPlexonTime);
    end;
end;
catch
    Values = fnResampleKofikoToPlexOLD(strctTsVar, afPlexonTime, strctSession) ;
end





return;


function [strctStimulusParams, strRandFile,afRecordingRange] = fnGetStimulusParametersForValidTrials(strctKofiko, strctSession,iParadigmIndex, abValidTrials)
S = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrStimulusIndex;
iStart = find(S.TimeStamp >= strctSession.m_fKofikoStartTS,1,'first');
iEnd = find(S.TimeStamp <= strctSession.m_fKofikoEndTS,1,'last');

% These two variables hold the list of stimuli displayed and their Kofiko timestamp
aiStimuli = squeeze(S.Buffer(iStart:iEnd));
afStimuli_TS_Kofiko = S.TimeStamp(iStart:iEnd);

aiStimuliOnEvent = find(aiStimuli > 0);
afTimeStamps = afStimuli_TS_Kofiko(aiStimuliOnEvent(abValidTrials));

strctStimulusParams.m_afStimulusON_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS.TimeStamp, ...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusON_MS.Buffer, afTimeStamps);

strctStimulusParams.m_afStimulusOFF_MS = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS.TimeStamp, ...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusOFF_MS.Buffer, afTimeStamps);

strctStimulusParams.m_afStimulusSizePix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix.TimeStamp, ...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.StimulusSizePix.Buffer, afTimeStamps);

if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams,'RotationAngle')
    strctStimulusParams.m_afRotationAngle = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RotationAngle.TimeStamp, ...
        strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RotationAngle.Buffer, afTimeStamps);
else
    strctStimulusParams.m_afRotationAngle = zeros(1,length(afTimeStamps));
end


strctStimulusParams.m_afNoiseLevel = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.NoiseLevel.TimeStamp, ...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.NoiseLevel.Buffer, afTimeStamps);

strctStimulusParams.m_aiNoiseIndex = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrNoiseIndex.TimeStamp, ...
    strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.CurrNoiseIndex.Buffer, afTimeStamps);


if isfield(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams,'RandFile')
    
    aiInd = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RandFile.TimeStamp >= strctSession.m_fKofikoStartTS & ...
        strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RandFile.TimeStamp <= strctSession.m_fKofikoEndTS);

    if isempty(aiInd)
        % File has been set before recording started.
        iIndex = find(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RandFile.TimeStamp <= strctSession.m_fKofikoStartTS,1,'last');
        assert(length(iIndex)==1);
        strRandFile = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_strctStimulusParams.RandFile.Buffer{iIndex };
    else
        assert(false);
    end

else
    fnWorkerLog('No Random file information found?!?! Assuming pink noise');
    strRandFile = '\\kofiko-23b\StimulusSet\ClassificationImage\a2fRand_Pink_100x100x6000_Alpha1p2.mat';
end



if isfield(strctKofiko.g_strctAppConfig,'m_strctElectrophysiology')
    
    afDepth = fnMyInterp1(strctKofiko.g_strctAppConfig.m_strctElectrophysiology.m_astrctGrids(1).m_astrctDepth.TimeStamp, ...
               strctKofiko.g_strctAppConfig.m_strctElectrophysiology.m_astrctGrids(1).m_astrctDepth.Buffer, afTimeStamps);

    afRecordingRange = [min(afDepth), max(afDepth)];
else
    afRecordingRange = [NaN,NaN];
end
return;



