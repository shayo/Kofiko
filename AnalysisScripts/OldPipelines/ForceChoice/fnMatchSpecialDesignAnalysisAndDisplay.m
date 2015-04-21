function [strctSpecialDesign] = fnMatchSpecialDesignAnalysisAndDisplay(strctConfig,strDesignName)

iNumSpecialDesigns = length(strctConfig.m_acSpecificAnalysis);
strctSpecialDesign = [];
if ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end

for iIter=1:iNumSpecialDesigns
    acFields = fieldnames(strctConfig.m_acSpecificAnalysis{iIter}.m_strctParams);
    for iFieldIter=1:length(acFields)
        if strncmpi(acFields{iFieldIter},'m_strDesignFile',length('m_strDesignFile'))
            strSpecialDesign = getfield(strctConfig.m_acSpecificAnalysis{iIter}.m_strctParams, acFields{iFieldIter});
            if strcmpi(strSpecialDesign, strDesignName)
               strctSpecialDesign = strctConfig.m_acSpecificAnalysis{iIter};
               if isfield(strctSpecialDesign,'m_acRaster') && isstruct(strctSpecialDesign.m_acRaster)
                   strctSpecialDesign.m_acRaster = {strctSpecialDesign.m_acRaster};
               end
               return;
            end
        end
    end
    
    
end

return;