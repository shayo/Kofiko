function fnParadigmBlockDesignCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  

bEventHandled = fnHandleJuiceEvents(strCallback,varargin{:});

switch strCallback
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
   
    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
    case 'MicroStimPanel'
        if strcmp(get(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible'),'off')
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible','on');
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible','off');
        else
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible','on')
        end
        
    case 'JuicePanel'
        if strcmp(get(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible'),'off')
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible','on');
            set(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible','off');
        else
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible','on');
        end
    case 'StimulusPanel'
        if strcmp(get(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible'),'off')
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible','on');
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible','off');
        else
            set(g_strctParadigm.m_strctControllers.m_strctJuiceControllers.m_hPanel,'visible','on');
            set(g_strctParadigm.m_strctControllers.m_strctStimulusControllers.m_hPanel,'visible','off');
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.m_hPanel,'visible','off');
        end
        
    case 'LoadList'
        fnParadigmToKofikoComm('JuiceOff');
        [strFile, strPath] = fnMyGetFile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt']);
        if strFile(1) ~= 0
            strImageList = [strPath,strFile];


            g_strctParadigm.m_iMachineState = 1;
            fnParadigmToStimulusServer('AbortRun');

            g_strctParadigm = fnTsSetVar(g_strctParadigm, 'ImageList', strImageList);

            [acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList);
            fnParadigmToStimulusServer('LoadImageList',acFileNames);
            fnKofikoClearTextureMemory();
            [g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
                 g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = ...
                 fnInitializeTexturesAux(acFileNames);
          
            set(g_strctParadigm.m_strctControllers.hImageList,'string',char(acFileNamesNoPath),'min',1,'max',length(acFileNames));
            fnTsSetVarParadigm('BlockNameList', {});
            fnTsSetVarParadigm('BlockImageIndicesList', {});
            fnTsSetVarParadigm('BlockRunOrder', {});

            set(g_strctParadigm.m_strctControllers.hBlockList,'String','','value',1);
            set(g_strctParadigm.m_strctControllers.hBlockRunList,'String','','value',1);
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'String','','value',1);

        end;
       

    case 'LoadBlockList'
        fnParadigmToKofikoComm('JuiceOff');
        [strFile, strPath] = fnMyGetFile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt']);
        if strFile(1) ~= 0
            strBlockList = [strPath,strFile];


            g_strctParadigm.m_iMachineState = 1;
            fnParadigmToStimulusServer('AbortRun');

            [acImageIndices,acBlockNames] = fnLoadMRIStyleBlockList(strBlockList);
            if isempty(acImageIndices)
                fnHidePTB();
                h=errordlg('Incorrect block format? Did you load the wrong list?1?!?','Error');
                waitfor(h);
                fnShowPTB();
            end

            g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockNameList', acBlockNames);
            g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockImageIndicesList', acImageIndices);
            fnTsSetVarParadigm('BlockRunOrder', {});
            
            set(g_strctParadigm.m_strctControllers.hBlockList,'String',char(acBlockNames),'value',1);
            set(g_strctParadigm.m_strctControllers.hBlockRunList,'String','','value',1);
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'String','','value',1);

        end;
 
    case 'FixationSizePix'
         fnParadigmToStimulusServer('UpdateFixationSize',fnTsGetVar(g_strctParadigm,'FixationSizePix'));
    case 'StimulusSizePix'
         fnParadigmToStimulusServer('UpdateStimulusSize',fnTsGetVar(g_strctParadigm,'StimulusSizePix'));
    case 'RotationAngle'
        fnParadigmToStimulusServer('UpdateRotationAngle',fnTsGetVar(g_strctParadigm,'RotationAngle'));
    case 'TR'
        g_strctParadigm.m_iMachineState = 1;
        fnUpdateListWithTime();
    case 'NumTRsPerBlock'
        g_strctParadigm.m_iMachineState = 1;
        fnUpdateListWithTime();
    case 'MRI_TRSlider'
        fnUpdateListWithTime();
    case 'MRI_TREdit'
        fnUpdateListWithTime();
    case 'NumTRSlider'
        fnUpdateListWithTime();
    case 'NumTREdit'
        fnUpdateListWithTime();
    case 'StimulusTimeMS'
        fnUpdateListWithTime();
        g_strctParadigm.m_iMachineState = 1;
    case 'StartRecording'   
        %fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
    case 'StopRecording' 
        iNumRecExp = length(g_strctParadigm.m_acExperimentDescription);
        g_strctParadigm.m_acExperimentDescription{end+1} = sprintf('Experiment %d', iNumRecExp+1);
        set(g_strctParadigm.m_strctControllers.hExpName,'String', char(g_strctParadigm.m_acExperimentDescription) );
        
    case 'ExperimentNameEdit'
        if isempty(g_strctParadigm.m_acExperimentDescription)
            return;
        end
        
        iSelectedExperiment = get( g_strctParadigm.m_strctControllers.hExpName,'value');
        strExperimentDescr = get(g_strctParadigm.m_strctControllers.m_hExpNameEdit,'String');
        
        g_strctParadigm.m_acExperimentDescription{iSelectedExperiment} = strExperimentDescr;
        
        set( g_strctParadigm.m_strctControllers.hExpName,'string', char(g_strctParadigm.m_acExperimentDescription));
        
    case 'SelectMicroStimBlocks'
        g_strctParadigm.m_iMachineState = 1;
    case 'SelectBlocks'
        iSelectedBlock = get(g_strctParadigm.m_strctControllers.hBlockList,'value');
        acBlockImageIndicesList = fnTsGetVar(g_strctParadigm, 'BlockImageIndicesList');
        set(g_strctParadigm.m_strctControllers.hImageList,'value',acBlockImageIndicesList{iSelectedBlock});
    case 'AddBlockToRun'
        iSelectedBlock = get(g_strctParadigm.m_strctControllers.hBlockList,'value');
        if ~isempty(iSelectedBlock)
            acBlockNameList = fnTsGetVar(g_strctParadigm, 'BlockNameList');
            acBlockRunOrder = fnTsGetVar(g_strctParadigm,'BlockRunOrder');
            iNumBlocks = length(acBlockRunOrder);
            acBlockRunOrder{iNumBlocks+1} = acBlockNameList{iSelectedBlock};
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'BlockRunOrder',acBlockRunOrder);
            
            fnUpdateListController(g_strctParadigm.m_strctControllers.hBlockRunList, acBlockRunOrder,iNumBlocks+1, true);
            
            aiSelection = get(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'value');
            fnUpdateListController(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList, acBlockRunOrder, aiSelection,true);
            
            aiMicroStim = find(get(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'value'));
            set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'String',acBlockRunOrder,'value',aiMicroStim);
            
            fnUpdateListWithTime();
        end
    case 'ToggleFixatioinAfterRun'
        g_strctParadigm.m_bFixationWhileNotScanning = ~g_strctParadigm.m_bFixationWhileNotScanning;
    case 'ChangeRunMode'
        fnUpdateListWithTime();
    case 'RemoveBlocksFromRun'
        
        acBlockRunOrder = fnTsGetVar(g_strctParadigm,'BlockRunOrder');
        abWithMicroStim = zeros(1,length(acBlockRunOrder))>0;
        abWithMicroStim(get(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'value')) = 1;
        
        aiSelected = get(g_strctParadigm.m_strctControllers.hBlockRunList,'value');
        acBlockRunOrder(aiSelected) = [];
        abWithMicroStim(aiSelected) = [];
        
        set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'String',acBlockRunOrder,'value',find(abWithMicroStim));
        
        g_strctParadigm = fnTsSetVar(g_strctParadigm,'BlockRunOrder',acBlockRunOrder);
        fnUpdateListController(g_strctParadigm.m_strctControllers.hBlockRunList, acBlockRunOrder,1, true);
        fnUpdateListWithTime();
    case 'MoveBlockDown'
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
    case 'MoveBlockUp'
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
    case 'SimulateTrigger'
        g_strctParadigm.m_bSimulatedTrigger = true;
    case 'SaveRun'
        [strFile, strPath] = fnMyPutFile('BlockOrder.txt');
         acBlocks = cellstr(get(g_strctParadigm.m_strctControllers.hBlockRunList,'string'));
        if strFile(1) ~= 0
            fnSaveBlockOrderListTextFile([strPath, strFile],acBlocks);
        end
    case 'LoadRun'
        fnParadigmToKofikoComm('JuiceOff');
        [strFile, strPath] = fnMyGetFile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt']);

        if strFile(1) ~= 0
            acBlocks = fnLoadBlockOrderListTextFile([strPath, strFile]);
            
            if ~all(ismember( acBlocks,cellstr(get(g_strctParadigm.m_strctControllers.hBlockList,'string'))))
                fnHidePTB;
                h=msgbox('Unknown file format ?!?!?! Maybe you loaded the wrong list?...');
                waitfor(h);
                fnShowPTB;
            else
                g_strctParadigm = fnTsSetVar(g_strctParadigm,'BlockRunOrder',acBlocks);
                set(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList,'String',acBlocks,'value',1:2:length(acBlocks));
                fnUpdateListController(g_strctParadigm.m_strctControllers.hBlockRunList, acBlocks,1, true);
                fnUpdateListWithTime();
                g_strctParadigm.m_iMachineState = 1;
            end
            
        end
      
        
    case 'AbortRun'
        fnAbortRun();
    case 'ToggleUseTrigger'
        g_strctParadigm.m_bUseTriggerToStart = get(g_strctParadigm.m_strctControllers.m_hUseTrig,'value');
    case 'LoadExperiment'
        fnParadigmToKofikoComm('JuiceOff');
        fnAbortRun();     
        [strFile, strPath] = fnMyGetFile([g_strctParadigm.m_strInitial_DefaultImageFolder,'*.txt']);
        if strFile(1) == 0
            return;
        end;
        
        strExperimentFile = [strPath,strFile];
        [acNames] = textread(strExperimentFile,'%s');
        strImageList = acNames{1};
        strBlockList = acNames{2};
        strRunList = acNames{3};
        if strFile(1) ~= 0
            % Load Image List
            g_strctParadigm.m_iMachineState = 1;
            fnParadigmToStimulusServer('AbortRun');
            g_strctParadigm = fnTsSetVar(g_strctParadigm, 'ImageList', strImageList);
            [acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList);
            if fnParadigmToKofikoComm('IsPaused')
	            fnParadigmToStimulusServer('Resume');
	            fnParadigmToStimulusServer('LoadImageList',acFileNames);
	            fnParadigmToStimulusServer('Pause');
		else
	            fnParadigmToStimulusServer('LoadImageList',acFileNames);
		end
            fnKofikoClearTextureMemory();
            [g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
                g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = ...
                fnInitializeTexturesAux(acFileNames);
            
            set(g_strctParadigm.m_strctControllers.hImageList,'string',char(acFileNamesNoPath));
            set(g_strctParadigm.m_strctControllers.hBlockList,'String','','value',1);
            set(g_strctParadigm.m_strctControllers.hBlockRunList,'String','','value',1);
            % Load Block List
            [acImageIndices,acBlockNames] = fnLoadMRIStyleBlockList(strBlockList);
            
            g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockNameList', acBlockNames);
            g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockImageIndicesList', acImageIndices);
            set(g_strctParadigm.m_strctControllers.hBlockList,'String',char(acBlockNames),'value',1);
            set(g_strctParadigm.m_strctControllers.hBlockRunList,'String','','value',1);
            
            

            % Load Run
            acBlocks = fnLoadBlockOrderListTextFile(strRunList);
            g_strctParadigm = fnTsSetVar(g_strctParadigm,'BlockRunOrder',acBlocks);
            fnUpdateListController(g_strctParadigm.m_strctControllers.hBlockRunList, acBlocks,1, true);
            
            fnUpdateListController(g_strctParadigm.m_strctControllers.m_strctMicroStimControllers.hBlockRunList, acBlocks,1:2:size(acBlocks,1),true);
            
            fnUpdateListWithTime();
        end
    case 'MicroStimCycleMS'
    case 'ToggleMicroStim'
        g_strctParadigm.m_bMicroStim = ~g_strctParadigm.m_bMicroStim;
        set(g_strctParadigm.m_strctControllers.m_hUseMicroStim,'value',g_strctParadigm.m_bMicroStim);
    otherwise
        if ~bEventHandled
            fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
        end

end;

return;


function fnUpdateListWithTime()
global g_strctParadigm
iValue = get(g_strctParadigm.m_strctControllers.m_hRunOptions,'value');
acOptions = {'Block TR With Repeats','Block TR','Stimulus Time'};
acBlockRunOrder = fnTsGetVar(g_strctParadigm, 'BlockRunOrder');
fnPrepareImageListWithTime(acOptions{iValue}, acBlockRunOrder);
set(g_strctParadigm.m_strctControllers.m_hNumTR,'String',sprintf('Num TR = %d', g_strctParadigm.m_iTotalTRs));
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
    set(g_strctParadigm.m_strctControllers.hExpName,'String', char(g_strctParadigm.m_acExperimentDescription));

end
