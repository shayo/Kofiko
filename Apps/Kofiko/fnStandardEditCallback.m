function fnStandardEditCallback(hSliderController, hEditController, VarName)
global g_strctParadigm

strTemp = get(hEditController,'string');
iValue = fnMyStr2Num(strTemp);
if ~isempty(iValue) 
    fnUpdateSlider(hSliderController, iValue);
    g_strctParadigm = fnTsSetVar(g_strctParadigm,VarName,iValue);
    feval(g_strctParadigm.m_strCallbacks,VarName);
end;


return;
