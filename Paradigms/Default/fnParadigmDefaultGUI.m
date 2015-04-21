function fnParadigmDefaultGUI()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctEyeCalib g_strctStimulusServer

% Note, always add controllers as fields to g_strctParadigm.m_strctControllers
% This way, they are automatically removed once we switch to another
% paradigm
[hParadigmPanel, iPanelHeight, iPanelWidth] = fnCreateParadigmPanel();
strctControllers.m_hPanel = hParadigmPanel;
strctControllers.m_hButton = uicontrol('Parent',hParadigmPanel,'Style', 'pushbutton', 'String', 'Example Button',...
    'Position', [5 iPanelHeight-60 100 50], 'Callback', [g_strctParadigm.m_strCallbacks,'(''CallbackExample'');']);
 
g_strctParadigm.m_strctControllers = strctControllers;
return;
