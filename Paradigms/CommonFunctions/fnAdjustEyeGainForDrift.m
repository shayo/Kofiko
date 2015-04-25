function fnAdjustEyeGainForDrift(afScreenEyePos)

global g_strctCycle g_strctStimulusServer g_strctEyeCalib


%pt2iFixationPoint = g_strctCycle.m_pt2fCurrentFixationPosition;
%pt2iScreenCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
afEyeOffset = afScreenEyePos(1:2) - (g_strctCycle.m_pt2fCurrentFixationPosition);
if abs(afEyeOffset(1)) > 1 &&  abs(afEyeOffset(2)) > 1
	[afGain(1),afGain(2),centerX,centerY] = fnTsGetVar('g_strctEyeCalib','GainX','GainY','CenterX','CenterY');
	fnTsSetVar('g_strctEyeCalib','CenterX',centerX(1)+(sign(afEyeOffset(1))/afGain(1)));
	fnTsSetVar('g_strctEyeCalib','CenterY',centerY(1)+(sign(afEyeOffset(2))/afGain(2)));
	
elseif abs(afEyeOffset(1)) > 1
	[afGain,centerX] = fnTsGetVar('g_strctEyeCalib','GainX','CenterX');
	fnTsSetVar('g_strctEyeCalib','CenterX',centerX(1)+(sign(afEyeOffset(1))/afGain(1)));
	
elseif abs(afEyeOffset(2)) > 1
	[afGain,centerY] = fnTsGetVar('g_strctEyeCalib','GainY','CenterY');
	fnTsSetVar('g_strctEyeCalib','CenterY',centerY(1)+(sign(afEyeOffset(2))/afGain));
end
%afEyeOffset = afScreenEyePos(1:2) - (g_strctCycle.m_pt2fCurrentFixationPosition);

%fEyeXPix = (afRAWEyeSig(1) - fCenterX)*fGainX + g_strctStimulusServer.m_aiScreenSize(3)/2;
%fEyeYPix = (afRAWEyeSig(2) - fCenterY)*fGainY + g_strctStimulusServer.m_aiScreenSize(4)/2;

%newCenterX = centerX(1)-sign(afEyeOffset(1))/afGain(1);
%newCenterY = centerY(1)-sign(afEyeOffset(2))/afGain(2);

%fprintf('afEyeOffset = %f,%f\n, centerX = %f\n,centerY = %f\n',afEyeOffset(1),afEyeOffset(2),centerX,centerY)
%fprintf('Adjusted gaze for drift. Values are [%d %d]',centerX(1)-sign(afEyeOffset(1)),centerY(1)-sign(afEyeOffset(2)))
%fnLog('Adjusted gaze for drift. Values are [%d %d]',centerX(1)-sign(afEyeOffset(1)),centerY(1)-sign(afEyeOffset(2)));

return;