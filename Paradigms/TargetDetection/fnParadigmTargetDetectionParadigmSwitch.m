function fnParadigmTargetDetectionParadigmSwitch(strEvent)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm

switch strEvent
    case 'Init'

        fnParadigmToKofikoComm('SetFixationPosition', g_strctParadigm.m_pt2fFixationSpot);


        strImageList = fnTsGetVar(g_strctParadigm,'ListFileName');
        if ~isempty(strImageList)
            fnParadigmToStimulusServer('LoadList',strImageList);
            [g_strctParadigm.m_strctObjects.m_ahPTBHandles, ...
                g_strctParadigm.m_strctObjects.m_a2iImageSize, ...
                g_strctParadigm.m_strctObjects.m_aiGroup, ...
                g_strctParadigm.m_strctObjects.m_afWeights, ...
                g_strctParadigm.m_strctObjects.m_acFileNamesNoPath] = fnLoadWeightedImageList(strImageList);
        end;
    case 'Close'
end


return;
