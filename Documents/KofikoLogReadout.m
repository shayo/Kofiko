Kofiko structure contains:

g_astrctAllParadigms

For example, to get fixation spot change event

g_astrctAllParadigms{2}.m_strctStimulusParams.FixationSpotPix
g_astrctAllParadigms{2}.m_strctStimulusParams.FixationSpotPix.Buffer
g_astrctAllParadigms{2}.m_strctStimulusParams.FixationSpotPix.TimeStamp

figure;plot(g_astrctAllParadigms{2}.m_strctStimulusParams.FixationSpotPix.Buffer(:,1),g_astrctAllParadigms{2}.m_strctStimulusParams.FixationSpotPix.Buffer(:,2))


Synchornization with stimulus server:

g_strctDAQParams.StimulusServerSync
g_strctDAQParams.StimulusServerSync.TimeStamp
g_strctDAQParams.StimulusServerSync.Buffer

[LocalTime,fServerTime,fJitter]

Passive fixation:

g_astrctAllParadigms{3}.ImageList.Buffer
List loaded, and at which time

g_astrctAllParadigms{3}.Trials.Buffer

[StimulusIndex, FlipON (stimulus server), Flip Off (stimulus server), Dummy, Local flip time, num frames displayed]
          
% Eye position:
g_strctEyeCalib.CenterX
g_strctEyeCalib.CenterY
g_strctEyeCalib.GainX
g_strctEyeCalib.GainY
g_strctEyeCalib.EyeRaw (X,Y,Pupil) & Timestamps

To convert to pixel coordinates use:

afEyeXpix = (RawX+2048 - OffsetX).*GainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (RawY+2048 - OffsetY).*GainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;

