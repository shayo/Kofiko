function fnParadigmHandMappingAddRealtimeSliderCallbackLength()
global g_strctParadigm


g_strctParadigm.m_strctControllers.m_hLengthSliderForUpdate = handle(g_strctParadigm.m_strctControllers.m_hLengthSlider);
g_strctParadigm.m_strctControllers.m_hLengthListenerVal = findprop(g_strctParadigm.m_strctControllers.m_hLengthSliderForUpdate,'Value');
g_strctParadigm.m_strctControllers.m_hLengthListener = handle.listener(g_strctParadigm.m_strctControllers.m_hLengthListenerVal, 'ActionEvent',@fnUpdateLengthValue);
setappdata(g_strctParadigm.m_strctControllers.m_hLengthSlider,'sliderListener',g_strctParadigm.m_strctControllers.m_hLengthListener);
%{





	Value = round(get(hSliderController,'value'));
	set(hEditController,'String',num2str(Value));
	g_strctParadigm = fnTsSetVar(g_strctParadigm,VarName,Value);
	feval(g_strctParadigm.m_strCallbacks,VarName);

	iNewStimulusLength = g_strctParadigm.Length.Buffer(g_strctParadigm.Length.BufferIdx);
	fnTsSetVarParadigm('Length',iNewStimulusLength);
	fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hLengthSlider, iNewStimulusLength);
	set(g_strctParadigm.m_strctControllers.m_hLengthEdit,'String',num2str(iNewStimulusLength));
		
		%}
return


function fnUpdateLengthValue()
global g_strctParadigm
	Value = round(get(g_strctParadigm.m_strctControllers.m_hLengthSlider,'value'));
	set(g_strctParadigm.m_strctControllers.m_hLengthEdit,'String',num2str(Value));
	g_strctParadigm = fnTsSetVar('g_strctParadigm','Length',Value);
	feval(g_strctParadigm.m_strCallbacks,'Length');
return