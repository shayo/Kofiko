function fnAddTimeStampedVariablesFromDesignToParadigmStructure(strctDesign, bResetGlobalVars)
global g_strctParadigm
iNumVars = length(strctDesign.m_astrctGlobalVars);
iSmallBuffer = 500;
fnClearDesignGlobalVarControllers();


for iVarIter=1:iNumVars
    if isfield(g_strctParadigm, strctDesign.m_astrctGlobalVars(iVarIter).m_strName)
        if bResetGlobalVars
            switch lower(strctDesign.m_astrctGlobalVars(iVarIter).m_strType)
                case 'numeric'
                    fnTsSetVarParadigm(strctDesign.m_astrctGlobalVars(iVarIter).m_strName,  ...
                        str2num(strctDesign.m_astrctGlobalVars(iVarIter).m_strValue));
                case 'boolean'
                    fnTsSetVarParadigm(strctDesign.m_astrctGlobalVars(iVarIter).m_strName,  ...
                        str2num(strctDesign.m_astrctGlobalVars(iVarIter).m_strValue)>0);
                otherwise
                    assert(false);
            end
        end
    else
        % Add new variable
        switch lower(strctDesign.m_astrctGlobalVars(iVarIter).m_strType)
            case 'numeric'
                g_strctParadigm = fnTsAddVar(g_strctParadigm, strctDesign.m_astrctGlobalVars(iVarIter).m_strName, ...
                    str2num(strctDesign.m_astrctGlobalVars(iVarIter).m_strValue), iSmallBuffer);
            case 'boolean'
                g_strctParadigm = fnTsAddVar(g_strctParadigm, strctDesign.m_astrctGlobalVars(iVarIter).m_strName, ...
                    str2num(strctDesign.m_astrctGlobalVars(iVarIter).m_strValue)>0, iSmallBuffer);
                
            otherwise
                assert(false);
        end;
    end
    
    if isfield(strctDesign.m_astrctGlobalVars(iVarIter),'m_strPanel') 
        % Create a GUI controller
        if ~isfield(strctDesign.m_astrctGlobalVars(iVarIter),'m_strDescription')
            strDescription = strctDesign.m_astrctGlobalVars(iVarIter).m_strName;
        else
            strDescription = strctDesign.m_astrctGlobalVars(iVarIter).m_strDescription;
        end
        
        if bResetGlobalVars
            fValue = str2num(strctDesign.m_astrctGlobalVars(iVarIter).m_strValue);
        else
           fValue = fnTsGetVar(g_strctParadigm, strctDesign.m_astrctGlobalVars(iVarIter).m_strName);
        end
        
        fMinSlider = 0;
        fMaxSlider = 2*fValue;
        if fMaxSlider == 0
            fMaxSlider = 1;
             afRange = [0 0.5];
        else
             afRange = [1, 5];
        end
       
         
        switch lower(strctDesign.m_astrctGlobalVars(iVarIter).m_strPanel)
            case 'reward'
                hPanel = g_strctParadigm.m_strctRewardControllers.m_hPanel;
                iCurrLinePos = 40+g_strctParadigm.m_strctRewardControllers.m_iNumElements*30;
                g_strctParadigm.m_strctRewardControllers.m_iNumElements=g_strctParadigm.m_strctRewardControllers.m_iNumElements+1;
            case 'stimuli'
                hPanel = g_strctParadigm.m_strctStimuliControllers.m_hPanel;
                iCurrLinePos = 40+g_strctParadigm.m_strctStimuliControllers.m_iNumElements*30;
                g_strctParadigm.m_strctStimuliControllers.m_iNumElements=g_strctParadigm.m_strctStimuliControllers.m_iNumElements+1;
            case 'timing'
                hPanel = g_strctParadigm.m_strctTimingControllers.m_hPanel;
                iCurrLinePos = 40+g_strctParadigm.m_strctTimingControllers.m_iNumElements*30;
                g_strctParadigm.m_strctTimingControllers.m_iNumElements=g_strctParadigm.m_strctTimingControllers.m_iNumElements+1;
            case 'microstim'
                hPanel = g_strctParadigm.m_strctMicroStimControllers.m_hPanel;
                iCurrLinePos = 40+g_strctParadigm.m_strctMicroStimControllers.m_iNumElements*30;
                g_strctParadigm.m_strctMicroStimControllers.m_iNumElements=g_strctParadigm.m_strctMicroStimControllers.m_iNumElements+1;
                
            otherwise
                assert(false);
        end
        
    switch lower(strctDesign.m_astrctGlobalVars(iVarIter).m_strType)
        case 'numeric'
            fnAddTextSliderEditComboSmallWithCallback3(hPanel, iCurrLinePos, ...
                    strDescription, strctDesign.m_astrctGlobalVars(iVarIter).m_strName, fMinSlider, fMaxSlider, afRange, fValue);        
        case 'boolean'
            fnAddTextCheckboxWithCallback(hPanel, iCurrLinePos, ...
                    strDescription, strctDesign.m_astrctGlobalVars(iVarIter).m_strName,fValue);        
            
    end
    
        
    end
    
end

return;


