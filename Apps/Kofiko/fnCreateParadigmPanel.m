function [hPanel,iPanelHeight, iPanelWidth] = fnCreateParadigmPanel()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global  g_strctGUIParams 
% aiFigPos = get(g_handles.figure1,'Position');
iPanelHeight = g_strctGUIParams.m_iLowerPanelHeight;
iPanelWidth = g_strctGUIParams.m_iPanelWidth;
% 

hPanel = uipanel('Units','Pixels','Position',...
    g_strctGUIParams.m_aiLowerPanelRect);

return;
