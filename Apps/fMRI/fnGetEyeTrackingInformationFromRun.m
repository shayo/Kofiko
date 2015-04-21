function [afDistToFixationSpot,abInsideStimRect,abInsideGazeRect,afStimulusSizePix,afGazeBoxPix,afEyeXpix,afEyeYpix] = fnGetEyeTrackingInformationFromRun(strctKofiko, afSampleTime,iParadigmIndex)
afStimulusSizePix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix.TimeStamp,strctKofiko.g_astrctAllParadigms{iParadigmIndex}.StimulusSizePix.Buffer(:,1),afSampleTime);
afGazeBoxPix = fnMyInterp1(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.GazeBoxPix.TimeStamp,strctKofiko.g_astrctAllParadigms{iParadigmIndex}.GazeBoxPix.Buffer(:,1),afSampleTime);

afEyeXRaw = fnMyInterp1(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp,strctKofiko.g_strctEyeCalib.EyeRaw.Buffer(:,1),afSampleTime);
afEyeYRaw = fnMyInterp1(strctKofiko.g_strctEyeCalib.EyeRaw.TimeStamp,strctKofiko.g_strctEyeCalib.EyeRaw.Buffer(:,2),afSampleTime);

afGainX = fnMyInterp1(strctKofiko.g_strctEyeCalib.GainX.TimeStamp,strctKofiko.g_strctEyeCalib.GainX.Buffer,afSampleTime);
afGainY = fnMyInterp1(strctKofiko.g_strctEyeCalib.GainY.TimeStamp,strctKofiko.g_strctEyeCalib.GainY.Buffer,afSampleTime);
afOffsetX = fnMyInterp1(strctKofiko.g_strctEyeCalib.CenterX.TimeStamp,strctKofiko.g_strctEyeCalib.CenterX.Buffer,afSampleTime);
afOffsetY = fnMyInterp1(strctKofiko.g_strctEyeCalib.CenterY.TimeStamp,strctKofiko.g_strctEyeCalib.CenterY.Buffer,afSampleTime);

% The way to convert Raw Eye signal from plexon to screen coordinates is:
afEyeXpix = (afEyeXRaw- afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (afEyeYRaw- afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
 
% Now, Test whether it was inside the rect box or not:
%afStimulusSizePix

pt2fFixation = strctKofiko.g_astrctAllParadigms{iParadigmIndex}.m_pt2fFixationSpot;

abInsideGazeRect = afEyeXpix >= (pt2fFixation(1) -  afGazeBoxPix) & afEyeXpix <= (pt2fFixation(1) +  afGazeBoxPix) & ...
                   afEyeYpix >= (pt2fFixation(2) -  afGazeBoxPix) & afEyeYpix <= (pt2fFixation(2) +  afGazeBoxPix);

abInsideStimRect = afEyeXpix >= (pt2fFixation(1) -  afStimulusSizePix) & afEyeXpix <= (pt2fFixation(1) +  afStimulusSizePix) & ...
                   afEyeYpix >= (pt2fFixation(2) -  afStimulusSizePix) & afEyeYpix <= (pt2fFixation(2) +  afStimulusSizePix);
               
afDistToFixationSpot = sqrt( (afEyeXpix- pt2fFixation(1)).^2 +  (afEyeYpix- pt2fFixation(2)).^2 );


return;
