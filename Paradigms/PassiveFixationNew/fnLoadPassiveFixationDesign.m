function bSuccess = fnLoadPassiveFixationDesign(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm     

bSuccess  = false;

fnParadigmToStimulusServer('PauseButRecvCommands');

fnParadigmToKofikoComm('ClearMessageBuffer');
fnParadigmToKofikoComm('DisplayMessageNow','Loading Image List...');
fnLog('Switching to a new list');
% This will pass on the message even if the draw cycle is paused....
strctDesign = fnLoadPassiveFixationDesignAux(strImageList);
if isempty(strctDesign)
    % Loading failed!
    return;
end;
g_strctParadigm.m_bJustLoaded = true;

g_strctParadigm.m_strctDesign = strctDesign;
fnInitializeParameterSweep();

g_strctParadigm.m_iNumStimuli = length(g_strctParadigm.m_strctDesign.m_astrctMedia);
if isfield(g_strctParadigm,'ImageList')
    fnTsSetVarParadigm('ImageList',strImageList);
else
    g_strctParadigm.m_strctStimulusParams =fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'ImageList',strImageList);
end


fnTsSetVarParadigm('Designs', strctDesign);

fnDAQWrapper('StrobeWord', fnFindCode('Image List Changed'));
    
g_strctParadigm.m_iLastStimulusPresentedIndex  = 0;
g_strctParadigm.m_strctCurrentTrial = [];
fnParadigmToKofikoComm('ResetStat');


    g_strctParadigm.m_iNumTimesBlockShown = 0;
    g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
    g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
    g_strctParadigm.m_iCurrentOrder = 1;
    iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
    iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
    if g_strctParadigm.m_bRandom
        [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
    else
        g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
    end
% Update order and  blocks

acBlockNames = {strctDesign.m_strctBlocksAndOrder.m_astrctBlocks.m_strBlockName};
acBlockNames = acBlockNames(strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(1).m_aiBlockIndexOrder);
acOrderNames = {strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder.m_strOrderName};

if isfield(g_strctParadigm,'m_strctControllers')
    set(g_strctParadigm.m_strctControllers.m_hBlockOrderPopup,'String',acOrderNames,'value',1);
    set(g_strctParadigm.m_strctControllers.m_hBlockLists,'String',acBlockNames,'value',1);
end


if g_strctParadigm.m_iMachineState > 0
    g_strctParadigm.m_iMachineState = 2; % This will prevent us to get stuck waiting for some stimulus server code
end
g_strctParadigm.m_bDoNotDrawThisCycle = true; % first, allow initialization of stuff, like selection of next image from the NEW image list

if fnParadigmToStatServerComm('IsConnected')
    if isempty(g_strctParadigm.m_strctDesign.m_a2bStimulusToCondition)
        % There is no category file defiend for this list.
        iNumStimuli =  length( g_strctParadigm.m_strctDesign.m_astrctMedia);
        g_strctParadigm.m_strctStatServerDesign.TrialTypeToConditionMatrix = zeros(iNumStimuli,0);
        g_strctParadigm.m_strctStatServerDesign.ConditionOutcomeFilter = cell(0);
        g_strctParadigm.m_strctStatServerDesign.ConditionNames = cell(0);
        g_strctParadigm.m_strctStatServerDesign.ConditionVisibility = [];
    else
        NumConditions = size(g_strctParadigm.m_strctDesign.m_a2bStimulusToCondition,2);
        g_strctParadigm.m_strctStatServerDesign.TrialTypeToConditionMatrix = g_strctParadigm.m_strctDesign.m_a2bStimulusToCondition;
        g_strctParadigm.m_strctStatServerDesign.ConditionOutcomeFilter = cell(1,NumConditions); % No need for fancy averaging according
        % to trial outcome, because we are going to drop all bad
        % fixations...
        g_strctParadigm.m_strctStatServerDesign.DesignName = strImageList;
        g_strctParadigm.m_strctStatServerDesign.ConditionNames = strctDesign.m_acConditionNames;
        g_strctParadigm.m_strctStatServerDesign.ConditionVisibility = g_strctParadigm.m_strctDesign.m_abVisibleConditions;
    end        
    fnParadigmToStatServerComm('SendDesign', g_strctParadigm.m_strctStatServerDesign);
    
end

bSuccess  = true;
return;




