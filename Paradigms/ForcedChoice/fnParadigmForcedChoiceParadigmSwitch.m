function fnParadigmForcedChoiceParadigmSwitch(strEvent)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm

switch strEvent
    case 'Init'
        % Switching from another paradigm to this one 
        fnParadigmToKofikoComm('SetFixationPosition', g_strctParadigm.m_pt2fFixationSpot);

        % No need to reallocate handles because they are generated on the
        % fly
        g_strctParadigm.m_iMachineState = 1;
        
        % fly
    case 'Close'
        % Switching from this paradigm to another
        if ~isempty(g_strctParadigm.m_ahPTBHandles)
            Screen('Close',g_strctParadigm.m_ahPTBHandles);
            g_strctParadigm.m_ahPTBHandles = [];
        end
         
end

return;
