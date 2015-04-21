function fnDrawAttention()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctPTB g_strctParadigm g_strctAppConfig
pt2iCenter = g_strctPTB.m_aiRect(3:4)/2;


fnParadigmToKofikoComm('JuiceOff');

if isfield(g_strctParadigm,'DrawAttentionEvents')
    g_strctParadigm = fnTsSetVar(g_strctParadigm, 'DrawAttentionEvents', 1);
else
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'DrawAttentionEvents', 1, 500);
end

if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    fnParadigmToStimulusServer('DrawAttention');
end


        
Screen(g_strctPTB.m_hWindow,'FillRect',[0 0 0]);
for j=1:3
    for k=1:10:100
        aiFixationSpot = [pt2iCenter(1) - k,pt2iCenter(2) - k,pt2iCenter(1) + k,pt2iCenter(2) + k];
        Screen(g_strctPTB.m_hWindow,'FillArc',[255,255,255], aiFixationSpot,0,360);
        Screen('Flip', g_strctPTB.m_hWindow);
    end;
end;
Screen(g_strctPTB.m_hWindow,'FillRect',[0 0 0]);
Screen('Flip', g_strctPTB.m_hWindow);

g_strctParadigm = fnTsSetVar(g_strctParadigm, 'DrawAttentionEvents', 0);

% Send a message to the paradigm that this event occured. We might want to
% reset trials or something....
feval(g_strctParadigm.m_strCallbacks,'DrawAttentionEvent');
return;