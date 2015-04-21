function [strSpecialAnalysisFunc, strDisplayFunction, strctSpecialAnalysis] = fnFindSpecialAnalysis(strctConfig,  strImageListUsed)
strctSpecialAnalysis = [];
strSpecialAnalysisFunc = '';
strDisplayFunction = strctConfig.m_strctGeneral.m_strDisplayFunction;
if ~isfield(strctConfig,'m_acSpecificAnalysis')
    iNumSpecificAnalysisAvail = 0;
else
    iNumSpecificAnalysisAvail = length(strctConfig.m_acSpecificAnalysis);    
end
if ~iscell(strctConfig.m_acSpecificAnalysis)
    strctConfig.m_acSpecificAnalysis = {strctConfig.m_acSpecificAnalysis};
end
for iSpecialIter=1:iNumSpecificAnalysisAvail
    acFieldNames = fieldnames(strctConfig.m_acSpecificAnalysis{iSpecialIter});
    iNumSubFields = length(acFieldNames);
    for k=1:iNumSubFields
        if strncmpi(acFieldNames{k},'m_strDesignName',length('m_strDesignName'))
            strDesignName = getfield(strctConfig.m_acSpecificAnalysis{iSpecialIter},acFieldNames{k});
            if strcmpi(strImageListUsed, strDesignName)
                strctSpecialAnalysis = strctConfig.m_acSpecificAnalysis{iSpecialIter};
                strSpecialAnalysisFunc = strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strAnalysisScript;
                strDisplayFunction = strctConfig.m_acSpecificAnalysis{iSpecialIter}.m_strDisplayScript;
                return;
            end
        end
    end
end
return; 
