function fnResumeFromCrashNoPTB()
global g_bParadigmRunning g_iCurrParadigm g_iNextParadigm g_bAppIsRunning g_astrctAllParadigms g_strctParadigm g_strctDAQParams g_strctPTB
global g_strctSystemCodes
% fnShowPTB();
g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;

try
   Screen('Flip', g_strctPTB.m_hWindow, 0, 0, 2);
catch
    % PTB crashed and also needs to be recovered...
    [g_strctPTB.m_hWindow, g_strctPTB.m_aiRect] = Screen(    'OpenWindow',g_strctPTB.m_iScreenIndex,[0 0 0],g_strctPTB.m_aiScreenRect);
    feval(g_strctParadigm.m_strParadigmSwitch,'Init');
end

while (g_bParadigmRunning)
        fnKofikoCycleClean();
 end;

% Just in case we were in a state in which the juicer was open.
fnParadigmToKofikoComm('JuiceOff');
fnLog('Closing juice valve');

% And clear the screen 
fnLog('Clearing screen');
fnParadigmToStimulusServer('ClearScreen');
fnDeleteCurrentGUI();

%if ~isempty(g_iCurrParadigm ) && g_iCurrParadigm > 0
g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;
%end;

while (g_bAppIsRunning)
    fnRunParadigm();
    g_iCurrParadigm = g_iNextParadigm;
end;

fnLog('Exitting Kofiko');
fnShutDown();
return;

