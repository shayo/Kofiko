function fnDrawAttentionStimServer()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctPTB 
pt2iCenter = g_strctPTB.m_aiRect(3:4)/2;

fnClear();

for j=1:3
    for k=1:10:100
        aiFixationSpot = [pt2iCenter(1) - k,pt2iCenter(2) - k,pt2iCenter(1) + k,pt2iCenter(2) + k];
        if g_strctPTB.m_bInStereoMode
            Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,0); % Left Eye
            Screen(g_strctPTB.m_hWindow,'FillArc',[255,255,255], aiFixationSpot,0,360);
            Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,1); % Right Eye
            Screen(g_strctPTB.m_hWindow,'FillArc',[255,255,255], aiFixationSpot,0,360);
        else
            Screen(g_strctPTB.m_hWindow,'FillArc',[255,255,255], aiFixationSpot,0,360);
        end
        fnFlipWrapper(g_strctPTB.m_hWindow);
    end;
end;
fnClear();
return;

function fnClear()
global g_strctPTB;
if g_strctPTB.m_bInStereoMode
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,0); % Left Eye
    Screen(g_strctPTB.m_hWindow,'FillRect',[0 0 0]);
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,1); % Right Eye
    Screen(g_strctPTB.m_hWindow,'FillRect',[0 0 0]);
else
    Screen(g_strctPTB.m_hWindow,'FillRect',[0 0 0]);
end
fnFlipWrapper(g_strctPTB.m_hWindow);

return;
