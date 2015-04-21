function fnParadigmBlockDesignParadigmSwitch(strEvent)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer

switch strEvent
    case 'Init'
        % Get the current image list
        strImageList = fnTsGetVar(g_strctParadigm, 'ImageList');
        if ~isempty(strImageList)
            fnParadigmToKofikoComm('JuiceOff');

            [acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList);
            fnParadigmToStimulusServer('LoadImageList',acFileNames);
            fnKofikoClearTextureMemory();

            [g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
                g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = ...
                fnInitializeTexturesAux(acFileNames);

            set(g_strctParadigm.m_strctControllers.hImageList,'string',char(acFileNamesNoPath),'min',1,'max',length(acFileNames));

        end

        if g_strctParadigm.m_iMachineState > 0
            g_strctParadigm.m_iMachineState = 1; % This will prevent us to get stuck waiting for some stimulus server code
        end

        pt2iScreenCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
        fnParadigmToKofikoComm('SetFixationPosition',pt2iScreenCenter);
    case 'Close'
        % Clear all images from memory!
          fnKofikoClearTextureMemory();
end
return;
