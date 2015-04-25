function aiStimulusRect = fnComputeStimulusRect(fStimulusHalfSizePix, aiTextureSize, pt2fCenterPos)
% Keep original aspect ratio, but stretch to desired size
if 0
iSizeOnScreen = 2*fStimulusHalfSizePix+1;
fScaleX = iSizeOnScreen / aiTextureSize(1);
fScaleY = iSizeOnScreen / aiTextureSize(2);

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
aiStimulusRect = [0, 0, 1024, 768];

return;