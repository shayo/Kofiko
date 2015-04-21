function fnResumeParadigm()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctSystemCodes g_handles g_strctCycle  g_strctAppConfig g_strctParadigm
if g_strctCycle.m_bParadigmPaused
    g_strctCycle.m_bParadigmPaused = false;
    % Machine is in pause mode. restore state
    fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iResumeParadigm);
    fnLog('Resuming %s paradigm', g_strctParadigm.m_strName);
    
    if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
        fnParadigmToStimulusServer('Resume');
    end
    
    feval(g_strctParadigm.m_strCallbacks,'Resuming');
    
    set(g_handles.hPauseButton,'String','Pause');
    g_strctCycle.m_iMotionFSM_State = 0;
end;
return;