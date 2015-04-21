function fnLoadDesignAux(strDesignFile)
global g_strctParadigm
strctDesign = fnLoadBlockDesignNewDesignFile(strDesignFile);
if isempty(strctDesign)
    fnParadigmToKofikoComm('DisplayMessage','Error in XML design file');
else
    
    g_strctParadigm.m_strctDesign = strctDesign;
    g_strctParadigm.m_iActiveOrder = 1;
    g_strctParadigm.m_iMachineState = 1;

    fnTsSetVarParadigm('Designs', g_strctParadigm.m_strctDesign);
    
    
     %Design in list already?
     iIndexInList = find(ismember(g_strctParadigm.m_acFavroiteLists,strDesignFile));
     if isempty(iIndexInList)
       g_strctParadigm.m_acFavroiteLists = [strDesignFile, g_strctParadigm.m_acFavroiteLists];
       set(g_strctParadigm.m_strctDesignControllers.m_hFavoriteDesigns,'value',1,'string',g_strctParadigm.m_acFavroiteLists);
     else
       set(g_strctParadigm.m_strctDesignControllers.m_hFavoriteDesigns,'value',iIndexInList);
     end
    
    fnClearDesignGlobalVarControllers();
    fnAddTimeStampedVariablesFromDesignToParadigmStructure(g_strctParadigm.m_strctDesign, false);
    
    % Generate the run-time list from the design
    g_strctParadigm.m_strctCurrentRun = fnPrepareStimuliTimingFromBlockDesign();
    % update number of TRs
    set(g_strctParadigm.m_strctDesignControllers.m_hNumTR,'string',sprintf('Num TRs : %d',sum(g_strctParadigm.m_strctCurrentRun.m_aiNumTRperBlock)));
    % Setup the block list according to the selected order.
    set(g_strctParadigm.m_strctDesignControllers.m_hBlockOrder,'string',g_strctParadigm.m_strctCurrentRun.m_acBlockNamesWithMicroStim);
    iNumRuns = length(strctDesign.m_acBlockOrders);
    acRunNames = cell(1,iNumRuns);
    for k=1:iNumRuns
        acRunNames{k} = strctDesign.m_acBlockOrders{k}.m_strName;
    end
    
    set(g_strctParadigm.m_strctDesignControllers.m_hDesignOrder,'string', acRunNames);
    
    if fnParadigmToKofikoComm('IsPaused')
        fnParadigmToStimulusServer('Resume');
        fnParadigmToStimulusServer('LoadImageList',{g_strctParadigm.m_strctDesign.m_astrctMedia.m_strFileName});
        fnParadigmToStimulusServer('Pause');
    else
        fnParadigmToStimulusServer('LoadImageList',{g_strctParadigm.m_strctDesign.m_astrctMedia.m_strFileName});
    end
    
    fnKofikoClearTextureMemory();
    
    [g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
        g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = ...
        fnInitializeTexturesAux({g_strctParadigm.m_strctDesign.m_astrctMedia.m_strFileName});
end