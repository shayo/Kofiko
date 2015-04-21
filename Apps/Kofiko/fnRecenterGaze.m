function fnRecenterGaze()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
 
global g_strctEyeCalib  g_strctSystemCodes g_strctDAQParams  g_strctStimulusServer g_strctCycle g_strctAppConfig g_strctAcquisitionServer

if g_strctDAQParams.m_fUseMouseClickAsEyePosition
   return;
end;
if strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'arduino')     
    LastEntry = g_strctEyeCalib.EyeRaw.BufferIdx;
    afRAWEyeSig = g_strctEyeCalib.EyeRaw.Buffer(1,:,LastEntry);
else
    [afRAWEyeSig] = fnDAQWrapper('GetAnalog',[g_strctDAQParams.m_fEyePortX,g_strctDAQParams.m_fEyePortY, g_strctDAQParams.m_fEyePortPupil]);
end
if isfield(g_strctAppConfig,'m_strctAcquisitionServer') && g_strctAcquisitionServer.m_bConnected
            fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['CalibrateEyePosition ',...
                num2str(g_strctCycle.m_pt2fCurrentFixationPosition(1)),' ',num2str(g_strctCycle.m_pt2fCurrentFixationPosition(2)),' ',...
                num2str(g_strctStimulusServer.m_aiScreenSize(3)),' ',num2str(g_strctStimulusServer.m_aiScreenSize(4))]);
end

fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iRecenterGaze);

% We can only recneter the gaze is the current paradigm is displaying a
% fixation spot somewhere on the screen....
% The way to convery raw eye signal to pixel coordinates is:
% [RawSignal-SingalOffset]*Gain + ScreenCenter = FixationPoint
% 
% Recentering only changes the signal offset. We assume the gain has
% already been set correctly.
% 
% Ideally, Fixation point is equal to screen center, so the whole thing
% reduces to SignalOffset = RawSignal (when the monkey is fixating at the
% center).
%
% Otherwise, we get:
% 
pt2iFixationPoint = g_strctCycle.m_pt2fCurrentFixationPosition;
pt2iScreenCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
afGain = [fnTsGetVar(g_strctEyeCalib,'GainX'),fnTsGetVar(g_strctEyeCalib,'GainY')];

afSingalOffset = afRAWEyeSig(1:2) - (pt2iFixationPoint-pt2iScreenCenter) ./ afGain;

g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'CenterX',afSingalOffset(1));
g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'CenterY',afSingalOffset(2));
fnLog('Recentered gaze. Values are [%d %d]',round(afSingalOffset(1)),round(afSingalOffset(2)));
return;
