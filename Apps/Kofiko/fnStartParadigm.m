function fnStartParadigm()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctSystemCodes g_strctGUIParams  g_handles
g_strctGUIParams.m_bUserPaused = false;
fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iStartParadigm);
fnLog('Starting %s paradigm',g_strctParadigm.m_strName);
if ~isfield(g_strctParadigm,'m_fStartParadigmTimer')
    g_strctParadigm.m_fStartParadigmTimer = GetSecs;
else
    % paradigm has started at some point...
    % If pause, resume
    fnResumeParadigm();
end
set(g_handles.hPauseButton,'string','Pause','enable','on');
feval(g_strctParadigm.m_strCallbacks,'Start')

return;

