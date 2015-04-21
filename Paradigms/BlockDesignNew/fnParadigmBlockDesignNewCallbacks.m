function fnParadigmBlockDesignNewCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  

bEventHandled = fnHandleJuiceEvents(strCallback,varargin{:});

switch strCallback
    case 'RestartTrial'
        % Critical parameter has changed. Abort (if running)
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('AbortRun');
        g_strctParadigm.m_iMachineState = 1;
         g_strctParadigm.m_strctCurrentRun = fnPrepareStimuliTimingFromBlockDesign();
         % update number of TRs
         set(g_strctParadigm.m_strctDesignControllers.m_hNumTR,'string',sprintf('Num TRs : %d',sum(g_strctParadigm.m_strctCurrentRun.m_aiNumTRperBlock)));
         % Setup the block list according to the selected order.
         set(g_strctParadigm.m_strctDesignControllers.m_hBlockOrder,'string',g_strctParadigm.m_strctCurrentRun.m_acBlockNamesWithMicroStim);
    case 'ChangeFixationColor'     
         
           fnParadigmToKofikoComm('JuiceOff');
        bParadigmPaused = fnParadigmToKofikoComm('IsPaused');

        if ~bParadigmPaused
            bPausing = true;
            fnPauseParadigm();
        else
            bPausing = false;
        end

        fnShowHideWind('PTB Onscreen window [10]:','hide');
        aiColor  = uisetcolor();
        fnShowHideWind('PTB Onscreen window [10]:','show');
        if length(aiColor) > 1
            fnTsSetVarParadigm('FixationSpotColor',round(aiColor*255));
         end;
        if bPausing
            fnResumeParadigm();
        end
    case 'ChangeBackgroundColor'
        fnParadigmToKofikoComm('JuiceOff');
        bParadigmPaused = fnParadigmToKofikoComm('IsPaused');

        if ~bParadigmPaused
            bPausing = true;
            fnPauseParadigm();
        else
            bPausing = false;
        end


        fnShowHideWind('PTB Onscreen window [10]:','hide');
        aiColor  = uisetcolor();
        fnShowHideWind('PTB Onscreen window [10]:','show');
        if length(aiColor) > 1
            fnTsSetVarParadigm('BackgroundColor',round(aiColor*255));
         end;
        if bPausing
            fnResumeParadigm();
        end
    case 'SelectBlockOrder'
         fnParadigmToKofikoComm('JuiceOff');
         fnParadigmToStimulusServer('AbortRun');
         g_strctParadigm.m_iActiveOrder = get(g_strctParadigm.m_strctDesignControllers.m_hDesignOrder,'value');
         g_strctParadigm.m_iMachineState = 1;
         g_strctParadigm.m_strctCurrentRun = fnPrepareStimuliTimingFromBlockDesign();
         % update number of TRs
         set(g_strctParadigm.m_strctDesignControllers.m_hNumTR,'string',sprintf('Num TRs : %d',sum(g_strctParadigm.m_strctCurrentRun.m_aiNumTRperBlock)));
         % Setup the block list according to the selected order.
         set(g_strctParadigm.m_strctDesignControllers.m_hBlockOrder,'string',g_strctParadigm.m_strctCurrentRun.m_acBlockNamesWithMicroStim);
    case 'FavoriteDesign'
        iSelectedDesign = get(g_strctParadigm.m_strctDesignControllers.m_hFavoriteDesigns,'value');
        fnLoadDesignAux(g_strctParadigm.m_acFavroiteLists{iSelectedDesign});  
    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
         
    case 'JuicePanel'
        iSelectedPanel = 2;
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(setdiff(1:4,iSelectedPanel)),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(iSelectedPanel),'visible','on');
    case 'StimulusPanel'
        iSelectedPanel = 1;
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(setdiff(1:4,iSelectedPanel)),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(iSelectedPanel),'visible','on');
    case 'DesignPanel'
        iSelectedPanel = 3;
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(setdiff(1:4,iSelectedPanel)),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(iSelectedPanel),'visible','on');
    case 'TimingPanel'
        iSelectedPanel = 4;
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(setdiff(1:4,iSelectedPanel)),'visible','off');
        set(g_strctParadigm.m_strctControllers.m_ahSubPanels(iSelectedPanel),'visible','on');
        
    case 'EditDesign'
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('AbortTrial');
        fnHidePTB();
        iSelected = get(g_strctParadigm.m_strctDesignControllers.m_hFavoriteDesigns,'value');
        eval(['!notepad ',g_strctParadigm.m_acFavroiteLists{iSelected}]);
        fnShowPTB();  
        fnLoadDesignAux(g_strctParadigm.m_acFavroiteLists{iSelected});  
        
    case 'LoadDesign'
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('AbortRun');
        g_strctParadigm.m_iMachineState = 1;
        [strFile, strPath] = fnMyGetFile('*.xml');
       
        if strFile(1) ~= 0
            strDesignFile = [strPath,strFile];
            fnLoadDesignAux(strDesignFile);
        end;
 
    case 'FixationSizePix'
         fnParadigmToStimulusServer('UpdateFixationSize',fnTsGetVar(g_strctParadigm,'FixationSizePix'));
    case 'StimulusSizePix'
         fnParadigmToStimulusServer('UpdateStimulusSize',fnTsGetVar(g_strctParadigm,'StimulusSizePix'));
    case 'RotationAngle'
        fnParadigmToStimulusServer('UpdateRotationAngle',fnTsGetVar(g_strctParadigm,'RotationAngle'));
    case 'TR'
        g_strctParadigm.m_iMachineState = 1;
        g_strctParadigm.m_strctCurrentRun = fnPrepareStimuliTimingFromBlockDesign();
    case 'StartRecording'   
        %fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
    case 'StopRecording' 
        iNumRecExp = length(g_strctParadigm.m_acExperimentDescription);
        g_strctParadigm.m_acExperimentDescription{end+1} = sprintf('Experiment %d', iNumRecExp+1);
        set(g_strctParadigm.m_strctDesignControllers.hExpName,'String', char(g_strctParadigm.m_acExperimentDescription) );
        
    case 'ExperimentNameEdit'
        if isempty(g_strctParadigm.m_acExperimentDescription)
            return;
        end
        
        iSelectedExperiment = get( g_strctParadigm.m_strctDesignControllers.hExpName,'value');
        strExperimentDescr = get(g_strctParadigm.m_strctDesignControllers.m_hExpNameEdit,'String');
        g_strctParadigm.m_acExperimentDescription{iSelectedExperiment} = strExperimentDescr;
        set( g_strctParadigm.m_strctDesignControllers.hExpName,'string', char(g_strctParadigm.m_acExperimentDescription));
    case 'ToggleFixatioinAfterRun'
        g_strctParadigm.m_bFixationWhileNotScanning = ~g_strctParadigm.m_bFixationWhileNotScanning;

    case 'SimulateTrigger'
        g_strctParadigm.m_bSimulatedTrigger = true;
    case 'AbortRun'
        fnAbortRun();
    case 'ToggleUseTrigger'
        g_strctParadigm.m_bUseTriggerToStart = get(g_strctParadigm.m_strctDesignControllers.m_hUseTrig,'value');
    otherwise
        if ~bEventHandled
            fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
        end

end;

return;



function fnAbortRun()
global g_strctParadigm
g_strctParadigm.m_iMachineState = 1;
g_strctParadigm.m_iLastFlippedImageIndex = [];
g_strctParadigm.m_iTriggerCounter = 0;
fnParadigmToKofikoComm('JuiceOff');

fnParadigmToStimulusServer('AbortRun');
if fnParadigmToKofikoComm('IsRecording')
    fnParadigmToKofikoComm('StopRecording',0);

    if isempty(g_strctParadigm.m_acExperimentDescription)
        g_strctParadigm.m_acExperimentDescription{1} = 'Aborted 1';
    else
        iNumRecExp = length(g_strctParadigm.m_acExperimentDescription);
        g_strctParadigm.m_acExperimentDescription{end} = sprintf('Aborted %d', iNumRecExp);
    end
    set(g_strctParadigm.m_strctDesignControllers.hExpName,'String', char(g_strctParadigm.m_acExperimentDescription));

end

