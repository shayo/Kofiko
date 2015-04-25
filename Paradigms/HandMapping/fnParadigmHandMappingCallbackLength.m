function fnParadigmHandMappingCallbackLength


		iNewStimulusLength = g_strctParadigm.Length.Buffer(g_strctParadigm.Length.BufferIdx);
		fnTsSetVarParadigm('Length',iNewStimulusLength);
		fnUpdateSlider(g_strctParadigm.m_strctControllers.m_hLengthSlider, iNewStimulusLength);
		set(g_strctParadigm.m_strctControllers.m_hLengthEdit,'String',num2str(iNewStimulusLength));
		varargout{1} = iNewStimulusLength;
		
		
return