function [aiImageList, afDisplayTimeMS, iTotalTRs] = fnPrepareImageListWithTime(strSelectedMode, acBlockRunList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  


acBlockImageIndicesList = fnTsGetVar(g_strctParadigm, 'BlockImageIndicesList');
acBlockNameList = fnTsGetVar(g_strctParadigm, 'BlockNameList');
fStimulusTimeMS = fnTsGetVar(g_strctParadigm ,'StimulusTimeMS');
fTR_MS = fnTsGetVar(g_strctParadigm,'TR');
iNumTRsPerBlock = fnTsGetVar(g_strctParadigm,'NumTRsPerBlock');

iTotalTRs = 0;
switch strSelectedMode
    case 'Stimulus Time'
        aiImageList = [];
        for k=1:length(acBlockRunList)
           iBlockIndex = find(ismember(lower(acBlockNameList), lower(acBlockRunList{k})));
            aiImageList = [aiImageList,acBlockImageIndicesList{iBlockIndex}];
        end
        iNumImages = length(aiImageList);
        afDisplayTimeMS = ones(1,iNumImages) * fStimulusTimeMS;
        fTotalTimeMS = sum(afDisplayTimeMS);
        iTotalTRs = ceil(fTotalTimeMS / fTR_MS);
    case 'Block TR'
        aiImageList = [];
        afDisplayTimeMS = [];
        for k=1:length(acBlockRunList)
            iBlockIndex = find(ismember(acBlockNameList,acBlockRunList{k}));
            aiIndices = acBlockImageIndicesList{iBlockIndex};
            aiImageList = [aiImageList,aiIndices];
            fTimePerImageMS = (iNumTRsPerBlock* fTR_MS)/length(aiIndices);
            afDisplayTimeMS = [afDisplayTimeMS, ones(1, length(aiIndices))*fTimePerImageMS];
        end
        iNumImages = length(aiImageList);
        afDisplayTimeMS = ones(1,iNumImages) * fStimulusTimeMS;
        fTotalTimeMS = sum(afDisplayTimeMS);
        iTotalTRs = ceil(fTotalTimeMS / fTR_MS);
        
   case 'Block TR With Repeats'
        aiImageList = [];
        afDisplayTimeMS = [];
        iTotalTRs = length(acBlockRunList) * iNumTRsPerBlock;
        for k=1:length(acBlockRunList)
            iBlockIndex = find(ismember(lower(acBlockNameList), lower(acBlockRunList{k})));
            aiIndices = acBlockImageIndicesList{iBlockIndex};
            
            fTimePerBlockMS = iNumTRsPerBlock* fTR_MS;
            iNumImagesToDisplay = floor(fTimePerBlockMS / fStimulusTimeMS);
            
            fTime = 0;
            iImageCounter = 1;
            iAllImagesInBlockCounter = 0;
            while fTime < fTimePerBlockMS
                aiImageList = [aiImageList, aiIndices(iImageCounter)];
                if g_strctParadigm.m_abIsMovie(aiIndices(iImageCounter))
                    fDisplayTime = g_strctParadigm.m_afMovieLengthSec(aiIndices(iImageCounter))*1e3;
                else
                    fDisplayTime = fStimulusTimeMS;
                end
                
                afDisplayTimeMS = [afDisplayTimeMS,fDisplayTime ];
                iImageCounter = iImageCounter + 1;
                iAllImagesInBlockCounter = iAllImagesInBlockCounter + 1;
                if iImageCounter > length(aiIndices)
                    iImageCounter = 1;
                end
                fTime = fTime + fDisplayTime;
            end
            if fTime > fTimePerBlockMS
                fDiff = fTimePerBlockMS-fTime;
                afDisplayTimeMS(end) = afDisplayTimeMS(end) + fDiff;
            end
            if iAllImagesInBlockCounter < length(aiIndices)
                fnParadigmToKofikoComm('DisplayMessage','Warning, not all images can be displayed with these parameters...');
            end
        end
    
end

g_strctParadigm.m_aiImageList = aiImageList;
g_strctParadigm.m_afDisplayTimeMS = afDisplayTimeMS;
g_strctParadigm.m_iTotalTRs = iTotalTRs;

return