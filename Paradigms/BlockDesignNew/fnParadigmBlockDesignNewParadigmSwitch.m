function fnParadigmBlockDesignNewParadigmSwitch(strEvent)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer

switch strEvent
    case 'Init'
        % Get the current image list
        if ~isempty(g_strctParadigm.m_acFavroiteLists)
            fnParadigmToKofikoComm('JuiceOff');
            iSelectedDesign = get(g_strctParadigm.m_strctDesignControllers.m_hFavoriteDesigns,'value');
            fnLoadDesignAux(g_strctParadigm.m_acFavroiteLists{iSelectedDesign});  
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
