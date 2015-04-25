function fnUpdateParadigmWithPTBSlider()
global g_strctPTB g_strctParadigm



switch g_strctParadigm.m_strCurrentlySelectedVariable
    case 'StimulusPosition'
        
        
        g_strctParadigm.m_aiCenterOfStimulus(1) = g_strctPTB.m_startingVariableValue(1) + ...
            ((g_strctPTB.m_strctControlInputs.m_mousePosition(1)-g_strctPTB.m_startingVariableValue(1)) +...
            g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1)) ;
			
        g_strctParadigm.m_aiCenterOfStimulus(2) = g_strctPTB.m_startingVariableValue(2) + ...
            ((g_strctPTB.m_strctControlInputs.m_mousePosition(2)-g_strctPTB.m_startingVariableValue(2)) +...
            g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2)) ;
			
        fnTsSetVarParadigm(g_strctParadigm.m_strCurrentlySelectedVariable, [g_strctPTB.m_startingVariableValue(1) + ...
            ((g_strctPTB.m_strctControlInputs.m_mousePosition(1)-g_strctPTB.m_startingVariableValue(1)) +...
            g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1)), ...
            g_strctPTB.m_startingVariableValue(2) + ((g_strctPTB.m_strctControlInputs.m_mousePosition(2)- ...
            g_strctPTB.m_startingVariableValue(2)) + g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2))]);
        
    otherwise
        ControllerSlider = ['g_strctParadigm.m_strctControllers.m_h', g_strctParadigm.m_strCurrentlySelectedVariable,'Slider'];
        ControllerEdit = ['g_strctParadigm.m_strctControllers.m_h', g_strctParadigm.m_strCurrentlySelectedVariable,'Edit'];
        % Set smart bounds on movement of variable
        fMax = get(eval(ControllerSlider),'max');
        fMin = get(eval(ControllerSlider),'min');
        mScale =  range([fMax,fMin])/ 1024 ; % Hardcoded 
        
        newValue = round(g_strctPTB.m_startingVariableValue - mScale* ...
            (g_strctPTB.m_startingMousePosition(1) - g_strctPTB.m_strctControlInputs.m_mousePosition(1)));
		% handle special cases, wraparound: orientation/gabor phase should revert to zero after passing 359, and vice versa
		if strcmp(g_strctParadigm.m_strCurrentlySelectedVariable, 'Orientation') || strcmp(g_strctParadigm.m_strCurrentlySelectedVariable, 'GaborPhase')
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
        fnTsSetVarParadigm(g_strctParadigm.m_strCurrentlySelectedVariable, newValue);
        % Update the GUI
        
        set(eval(ControllerSlider),'value',newValue,'max', max(fMax,newValue), 'min',min(fMin,newValue));
        set(eval(ControllerEdit),'String', num2str(newValue));
end
return;