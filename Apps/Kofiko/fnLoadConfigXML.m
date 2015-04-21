function [strctConfig,astrctParadigms] = fnLoadConfigXML(strConfigurationFile)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

tree = xmltree(strConfigurationFile);
iNumParadigms = 0;
iNumElectrodes = 0;
iElectrodesRoot = 0;
iNumPop = 0;
iParadigmAnal = 0;
iUpdate = 0;
for k=1:length(tree)
    strctRoot=get(tree,k);
    if strcmpi(strctRoot.type,'element') 
   % fprintf('%s\n',strctRoot.name);
        
        if strcmpi(strctRoot.name,'Paradigm')
            iNumParadigms = iNumParadigms + 1;
            strHostVar = ['astrctParadigms{',num2str(iNumParadigms),'}'];
            strctRoot.name = '';
        elseif strcmpi(strctRoot.name,'ParadigmAnalysis')
            iParadigmAnal = iParadigmAnal+ 1;
            strHostVar = ['strctConfig.m_acParadigmsAnalysis{',num2str(iParadigmAnal),'}'];
            strctRoot.name = '';
        elseif strcmpi(strctRoot.name,'Update')
            iUpdate = iUpdate+ 1;
            strHostVar = ['strctConfig.m_acUpdateAnalysis{',num2str(iUpdate),'}'];
            strctRoot.name = '';    
        elseif strcmpi(strctRoot.name,'Analysis')
            iNumPop = iNumPop+ 1;
            strHostVar = ['strctConfig.m_acPopulationAnalysis{',num2str(iNumPop),'}'];
            strctRoot.name = '';
           elseif strcmpi(strctRoot.name,'Electrodes')
            iElectrodesRoot = strctRoot.uid;
        elseif strcmpi(strctRoot.name,'Grid')
            strHostVar = 'strctConfig.m_strctElectrophysiology';
            strctRoot.name = '.m_strctGrid';
        elseif (strcmpi(strctRoot.name,'Electrode') && strctRoot.uid ~= iElectrodesRoot)
            iNumElectrodes = iNumElectrodes + 1;
            strHostVar = ['strctConfig.m_strctElectrophysiology.m_astrctElectrodes(',num2str(iNumElectrodes),')'];
            strctRoot.name = '';
        else
            strHostVar = 'strctConfig.m_strct';
        end;
        
       for iIter=1:length(strctRoot.attributes)           
           val = strctRoot.attributes{iIter}.val;
           afval = fnMyStringToDouble(val);
           bNumeric = ~isempty(afval);
           if bNumeric
               if length(afval) > 1
                   strCmd = [strHostVar,strctRoot.name,'.m_af',strctRoot.attributes{iIter}.key,' = [',val,']; '];
               else
                   strCmd = [strHostVar,strctRoot.name,'.m_f',strctRoot.attributes{iIter}.key,' = ',val,'; '];
               end;
           else
               if strcmp(val,'[]')
                   strCmd = [strHostVar,strctRoot.name,'.m_f',strctRoot.attributes{iIter}.key,' = ',val,'; '];
               else
                    strCmd = [strHostVar,strctRoot.name,'.m_str',strctRoot.attributes{iIter}.key,' = ''',val,'''; '];
               end
           end;
           eval(strCmd);
       end;
       
    end;
end;

if ~exist('astrctParadigms','var')
    astrctParadigms = [];
end;

return;


           
