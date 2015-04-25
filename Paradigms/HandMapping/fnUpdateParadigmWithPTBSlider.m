function fnUpdateParadigmWithPTBSlider()
global g_strctPTB g_strctParadigm



switch g_strctParadigm.m_bCurrentlySelectedVariable
    case 'StimulusPosition'
        
        
        g_strctParadigm.m_bCenterOfStimulus(1) = g_strctPTB.m_startingVariableValue(1) + ...
            ((g_strctPTB.m_strctControlInputs.m_mousePosition(1)-g_strctPTB.m_startingVariableValue(1)) +...
            g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1)) ;
        g_strctParadigm.m_bCenterOfStimulus(2) = g_strctPTB.m_startingVariableValue(2) + ...
            ((g_strctPTB.m_strctControlInputs.m_mousePosition(2)-g_strctPTB.m_startingVariableValue(2)) +...
            g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2)) ;
        fnTsSetVarParadigm(g_strctParadigm.m_bCurrentlySelectedVariable, [g_strctPTB.m_startingVariableValue(1) + ...
            ((g_strctPTB.m_strctControlInputs.m_mousePosition(1)-g_strctPTB.m_startingVariableValue(1)) +...
            g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1)), ...
            g_strctPTB.m_startingVariableValue(2) + ((g_strctPTB.m_strctControlInputs.m_mousePosition(2)- ...
            g_strctPTB.m_startingVariableValue(2)) + g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2))]);
        
    otherwise
        Controller = ['g_strctParadigm.m_strctControllers.m_h', g_strctParadigm.m_bCurrentlySelectedVariable];
        % Set smart bounds on movement of variable
        fMax = get(eval([Controller, 'Slider']),'max');
        fMin = get(eval([Controller, 'Slider']),'min');
        mScale =  range([fMax,fMin])/ 1024 ; % Hardcoded 
        
        newValue = round(g_strctPTB.m_startingVariableValue - mScale* ...
            (g_strctPTB.m_startingMousePosition(1) - g_strctPTB.m_strctControlInputs.m_mousePosition(1)));
		% handle special cases, wraparound: orientation should revert to zero after passing 359, and vice versa
		if strcmp(g_strctParadigm.m_bCurrentlySelectedVariable, 'Orientation') || strcmp(g_strctParadigm.m_bCurrentlySelectedVariable, 'GaborPhase')
			if newValue < fMin || newValue > fMax
				newValue = newValue - floor(newValue/fMax)*fMax;
			end
		else
			if newValue < fMin
				newValue = fMin;
			elseif newValue > fMax
				newValue = fMax;
			end
        end
        fnTsSetVarParadigm(g_strctParadigm.m_bCurrentlySelectedVariable, newValue);
        % Update the GUI
        
        set(eval([Controller, 'Slider']),'value',newValue,'max', max(fMax,newValue), 'min',min(fMin,newValue));
        set(eval([Controller, 'Edit']),'String', num2str(newValue));
end
return;