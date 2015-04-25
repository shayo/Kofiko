function aiStimulusRect = fnComputeStimulusRect(fStimulusHalfSizePix, aiTextureSize, pt2fCenterPos)


global g_strctPTB
if isempty(g_strctPTB.m_bFitToScreen)
	disp('work goddammit')
end
% Keep original aspect ratio, but stretch to desired size
iSizeOnScreen = 2*fStimulusHalfSizePix+1;
fScaleX = iSizeOnScreen / aiTextureSize(1);
fScaleY = iSizeOnScreen / aiTextureSize(2);
if g_strctPTB.m_bFitToScreen
	iStartX = 0;
	iEndX = g_strctStimulusServer.m_aiScreenSize(3);
	iStartY = 0;
	iEndY = g_strctStimulusServer.m_aiScreenSize(4);

else
	if fScaleX < fScaleY
    iStartX = pt2fCenterPos(1) - round(aiTextureSize(1) * fScaleX / 2);
    iEndX = pt2fCenterPos(1) + round(aiTextureSize(1) * fScaleX / 2);
    iStartY = pt2fCenterPos(2) - round(aiTextureSize(2) * fScaleX / 2);
    iEndY = pt2fCenterPos(2) + round(aiTextureSize(2) * fScaleX / 2);
	else
    iStartX = pt2fCenterPos(1) - round(aiTextureSize(1) * fScaleY / 2);
    iEndX = pt2fCenterPos(1) + round(aiTextureSize(1) * fScaleY / 2);
    iStartY = pt2fCenterPos(2) - round(aiTextureSize(2) * fScaleY / 2);
    iEndY = pt2fCenterPos(2) + round(aiTextureSize(2) * fScaleY / 2);
	end
end
aiStimulusRect = [iStartX, iStartY, iEndX, iEndY];

return;