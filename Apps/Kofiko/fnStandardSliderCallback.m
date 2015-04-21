function fnStandardSliderCallback(hSliderController, hEditController, VarName)
global g_strctParadigm
Value = round(get(hSliderController,'value'));
set(hEditController,'String',num2str(Value));
g_strctParadigm = fnTsSetVar(g_strctParadigm,VarName,Value);
feval(g_strctParadigm.m_strCallbacks,VarName);

return;
