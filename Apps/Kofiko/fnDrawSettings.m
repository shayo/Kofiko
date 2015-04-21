function fnDrawSettings()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_handles g_strctCycle g_strctGUIParams
hold(g_handles.m_strctSettingsPanel.m_hMotionAxes,'off');
plot(g_handles.m_strctSettingsPanel.m_hMotionAxes, g_strctCycle.m_afMaxMotion);
hold(g_handles.m_strctSettingsPanel.m_hMotionAxes,'on');
plot(g_handles.m_strctSettingsPanel.m_hMotionAxes, g_strctCycle.m_iMaxMotionIndex, g_strctCycle.m_afMaxMotion(g_strctCycle.m_iMaxMotionIndex),'ro');
plot(g_handles.m_strctSettingsPanel.m_hMotionAxes,[1 length(g_strctCycle.m_afMaxMotion)],[ g_strctGUIParams.m_fMotionThreshold, g_strctGUIParams.m_fMotionThreshold],'g');
return;
