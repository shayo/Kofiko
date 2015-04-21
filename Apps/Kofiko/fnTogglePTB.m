function fnTogglePTB()
global g_strctGUIParams
g_strctGUIParams.m_bDisplayPTB = ~g_strctGUIParams.m_bDisplayPTB;
if g_strctGUIParams.m_bDisplayPTB
    fnShowPTB();
else
    fnHidePTB();
end
return;
