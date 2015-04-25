GUI stimulus position mouse update code
if g_strctPTB.m_stimulusAreaUpdating && g_strctPTB.m_strctControlInputs.m_mouseButtons(1)
    g_strctParadigm.m_bCenterOfStimulus(1) = g_strctPTB.m_lastStimulusPosition(1) + ...
        ((g_strctPTB.m_strctControlInputs.m_mousePosition(1)-g_strctPTB.m_lastStimulusPosition(1)) +...
        g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1)) ;
    g_strctParadigm.m_bCenterOfStimulus(2) = g_strctPTB.m_lastStimulusPosition(2) + ...
        ((g_strctPTB.m_strctControlInputs.m_mousePosition(2)-g_strctPTB.m_lastStimulusPosition(2)) +...
        g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2)) ;
    %g_strctParadigm.m_bCenterOfStimulus(1) = g_strctParadigm.m_bCenterOfStimulus(1);
    %g_strctParadigm.m_bCenterOfStimulus(2) = g_strctParadigm.m_bCenterOfStimulus(2);
    g_strctParadigm.m_bStimulusRect(1) = round(g_strctParadigm.m_bCenterOfStimulus(1)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_bStimulusRect(2) = round(g_strctParadigm.m_bCenterOfStimulus(2)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_bStimulusRect(3) = round(g_strctParadigm.m_bCenterOfStimulus(1)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_bStimulusRect(4) = round(g_strctParadigm.m_bCenterOfStimulus(2)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    
    % The mouse is inside the PTB screen, we should check to see if it's being used to update things
    % If the mouse is inside the stimulus presentation area and the mouse button is down...
    % Update the stimulus area to be the new mouse position
    g_strctPTB.m_strctControlInputs.m_bLastStimulusPositionCheck = fCurrTime;
elseif	 ~g_strctPTB.m_stimulusAreaUpdating  && g_strctPTB.m_strctControlInputs.m_mousePosition(1) >= g_strctParadigm.m_bStimulusRect(1) && ...
        g_strctPTB.m_strctControlInputs.m_mousePosition(2) >= g_strctParadigm.m_bStimulusRect(2) && ...
        g_strctPTB.m_strctControlInputs.m_mousePosition(1) <= g_strctParadigm.m_bStimulusRect(3) && ...
        g_strctPTB.m_strctControlInputs.m_mousePosition(2) <= g_strctParadigm.m_bStimulusRect(4) && ...
        g_strctPTB.m_strctControlInputs.m_mouseButtons(1)
    % Start the stimulus update process
    g_strctPTB.m_stimulusAreaUpdating = true;
    g_strctPTB.m_lastStimulusPosition = g_strctParadigm.m_bCenterOfStimulus; % Center of stimulus in screen coordinates
    
    % Calculate the mouse offset (how far the mouse is from the stimulus center, so the stimulus moves proportional to the mouse starting point and not the stimulus center)
    g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(1) = ...
        g_strctPTB.m_lastStimulusPosition(1) - g_strctPTB.m_strctControlInputs.m_mousePosition(1);
    g_strctPTB.m_strctControlInputs.m_stimulusMovementMouseOffset(2) = ...
        g_strctPTB.m_lastStimulusPosition(2) - g_strctPTB.m_strctControlInputs.m_mousePosition(2) ;
    g_strctPTB.m_strctControlInputs.m_bLastStimulusPositionCheck = fCurrTime;
elseif g_strctPTB.m_stimulusAreaUpdating && ~g_strctPTB.m_strctControlInputs.m_mouseButtons(1)
    % end the stimulus position update
    g_strctPTB.m_stimulusAreaUpdating = false;
else
    % Update the stimulus rectangle
    g_strctParadigm.m_bStimulusRect(1) = round(g_strctParadigm.m_bCenterOfStimulus(1)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_bStimulusRect(2) = round(g_strctParadigm.m_bCenterOfStimulus(2)-(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_bStimulusRect(3) = round(g_strctParadigm.m_bCenterOfStimulus(1)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
    g_strctParadigm.m_bStimulusRect(4) = round(g_strctParadigm.m_bCenterOfStimulus(2)+(squeeze(g_strctParadigm.StimulusArea.Buffer(1,:,g_strctParadigm.StimulusArea.BufferIdx)/2)));
end