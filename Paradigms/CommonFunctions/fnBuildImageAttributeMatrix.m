function [acAllAttributes,a2bMediaAttributes] = fnBuildImageAttributeMatrix(astrctMedia)
acAllAttributes = unique(cat(2,astrctMedia.m_acAttributes));
iNumMedia = length(astrctMedia);
iNumAttributes = length(acAllAttributes);
a2bMediaAttributes = zeros(iNumMedia,iNumAttributes) >0;
if iNumAttributes == 0
    return;
end;
for iMediaIter=1:iNumMedia
        a2bMediaAttributes(iMediaIter,:) = ismember(acAllAttributes,astrctMedia(iMediaIter).m_acAttributes);
end

return;
