function [varargout] = fnDynamicCallback(strCallback,varargin)
global  g_strctParadigm

	g_strctParadigm.m_strCurrentlySelectedVariable = strCallback;

	iNewVal = g_strctParadigm.(strCallback).Buffer(g_strctParadigm.(strCallback).BufferIdx);
	fnTsSetVarParadigm(strCallback,iNewVal);
	fnUpdateSlider(g_strctParadigm.m_strctControllers.(['m_h',strCallback,'Slider']), iNewVal);
	set(g_strctParadigm.m_strctControllers.(['m_h',strCallback,'Edit']),'String',num2str(iNewVal));
	varargout{1} = iNewVal;
return;

