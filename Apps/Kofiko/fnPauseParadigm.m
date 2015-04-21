function fnPauseParadigm()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global  g_strctSystemCodes  g_handles g_strctCycle  g_strctDAQParams g_strctAppConfig g_strctParadigm
if ~g_strctCycle.m_bParadigmPaused
    % Machine is actually running. Pause
    g_strctCycle.m_bParadigmPaused = true;
    % Make sure monkey doesn't accidently get juice if we paused during
    % juice event
    fnDAQWrapper('SetBit',g_strctDAQParams.m_fJuicePort, 0);
    fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iJuiceOFF);
    
    fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iPauseParadigm);
    
    if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
        fnParadigmToStimulusServer('Pause');
    end
    feval(g_strctParadigm.m_strCallbacks,'Pausing');
    
    
    
    set(g_handles.hPauseButton, 'String','Resume','enable','on');
    g_strctCycle.m_fStartPause = GetSecs;
end;
return;