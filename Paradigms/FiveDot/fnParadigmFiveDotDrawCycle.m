function fnParadigmFiveDotDrawCycle(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)



global g_strctPTB g_strctDraw g_strctNet g_strctServerCycle

if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    switch strCommand
        case 'Display'
            g_strctDraw.m_pt2fPos = acInputFromKofiko{2};
            g_strctDraw.m_fSize = acInputFromKofiko{3};
            g_strctDraw.m_afBackgroundColor = acInputFromKofiko{4};
            g_strctServerCycle.m_iMachineState = 1;
    end
end;

switch g_strctServerCycle.m_iMachineState
    case 0
        % Do nothing
    case 1
        Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_afBackgroundColor, g_strctPTB.m_aiRect);
        aiFixationSpot = [...
            g_strctDraw.m_pt2fPos(1) - g_strctDraw.m_fSize,...
            g_strctDraw.m_pt2fPos(2) - g_strctDraw.m_fSize,...
            g_strctDraw.m_pt2fPos(1) + g_strctDraw.m_fSize,...
            g_strctDraw.m_pt2fPos(2) + g_strctDraw.m_fSize];

        Screen(g_strctPTB.m_hWindow,'FillArc',[255 255 255], aiFixationSpot,0,360);
        g_strctServerCycle.m_iMachineState = 0;

        g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow, 0, 0, 2);
end

return;

