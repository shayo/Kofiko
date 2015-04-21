function fnFocusCallback(a,b, strEvent)
global g_strctCycle
fprintf('%s \n',strEvent);
switch strEvent
    case 'Gained'
        g_strctCycle.m_bKeyboardListen = false;
    case 'Lost'
        g_strctCycle.m_bKeyboardListen = true;
end


return;
