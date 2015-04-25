function fnUpdateForceChoiceDesignTable()
global g_strctParadigm
if ~isempty(g_strctParadigm.m_strctDesign) &&   strcmpi(g_strctParadigm.m_strctDesign.m_strctOrder.m_strTrialOrderType,'Blocks')
    iNumBlocks = length(g_strctParadigm.m_strctDesign.m_strctOrder.m_acTrialTypeIndex);
    a2cData = cell(iNumBlocks,3);
    for iBlockIter=1:iNumBlocks 
        a2cData{iBlockIter,1} = g_strctParadigm.m_strctDesign.m_strctOrder.m_acBlockNames{iBlockIter};
        a2cData{iBlockIter,2} = num2str(g_strctParadigm.m_strctDesign.m_strctOrder.m_acTrialTypeIndex{iBlockIter});
        a2cData{iBlockIter,3} = g_strctParadigm.m_strctDesign.m_strctOrder.m_aiNumTrialsPerBlock(iBlockIter);
    end
    set(g_strctParadigm.m_strctDesignControllers.m_hTrialBlocksTable,'Data',a2cData);
else
end

  iNumTrialTypes = length(g_strctParadigm.m_strctDesign.m_acTrialTypes);
  acTrialTypeNames = cell(1, iNumTrialTypes );
  for k=1:iNumTrialTypes
      acTrialTypeNames{k}  = sprintf('%d] %s',k,g_strctParadigm.m_strctDesign.m_acTrialTypes{k}.TrialParams.Name);
  end
  
set(g_strctParadigm.m_strctDesignControllers.m_hTrialTypeList ,'String', acTrialTypeNames,'min',1,'max',iNumTrialTypes);
return;
