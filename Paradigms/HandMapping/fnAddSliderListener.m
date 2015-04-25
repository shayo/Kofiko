function fnAddSliderListener(strctControllers,strVarName)

global g_strctParadigm

strTextVar = ['m_h',strVarName,'Text'];
strSliderVar = ['m_h',strVarName,'Slider'];
strEditVar = ['m_h',strVarName,'Edit'];
strSliderListenerVar = ['m_h', strVarName,'Listener'];
strSliderHandleForListenerVar = ['m_h', strVarName,'HandleForListener'];






function UpdateField()
global g_strctParadigm

g_strctParadigm.strctControllers.(strSliderHandleForListenerVar) = handle(g_strctParadigm.strctControllers.(strSliderVar));
g_strctParadigm.strctControllers.(strSliderListenerVar) = findprop(g_strctParadigm.strctControllers.(strSliderHandleForListenerVar),'Value');
g_strctParadigm.strctControllers.(strSliderListenerVar) = handle.listener(g_strctParadigm.strctControllers.(strSliderHandleForListenerVar), 'ActionEvent',@updateField);
setappdata(g_strctParadigm.strctControllers.(strSliderHandleForListenerVar),'sliderListener',g_strctParadigm.strctControllers.(strSliderListenerVar));


feval(g_strctParadigm.m_strCallbacks, g_strctParadigm.m_strCurrentGUIObject);
return;