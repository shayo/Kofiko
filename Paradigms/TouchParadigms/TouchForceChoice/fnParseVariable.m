function Value = fnParseVariable(strctSubStructure, strFieldName, DefaultValue, iIndexInArray)
global g_strctParadigm
% First, try to match against known global variables....
if ~isfield(strctSubStructure, strFieldName)
    Value = DefaultValue;
else
    ValueXML = getfield(strctSubStructure, strFieldName);
    
    if exist('iIndexInArray','var')
         % Accessing an array. Get only the relevant index.
         if iscell(ValueXML) && length(ValueXML) > 1
             ValueXML = ValueXML{iIndexInArray};
         else
            acEntries = fnSplitString(ValueXML,' ');
            if iIndexInArray > length(acEntries)
                iIndexInArray = 1;
            end
            ValueXML = acEntries{iIndexInArray};
         end
    end
    % User specified that field. It can be either a global variable or
    % actual value.
    % First, search the known global variable list to see if there is a
    % match
    iNumGlobalVars = length(g_strctParadigm.m_strctDesign.m_astrctGlobalVars);
    for iVarIter=1:iNumGlobalVars
        if strcmp(g_strctParadigm.m_strctDesign.m_astrctGlobalVars(iVarIter).m_strName,ValueXML)
            % This is indeed a global variable!
            % We should have a time stampped variable with that name!
            Value = fnTsGetVar(g_strctParadigm, ValueXML);
            return;
        end
    end
    % If we reached here. It is not a global variable
    % Try to convert it to a numeric?
    Value = str2num(ValueXML);
    if isempty(Value)
        fprintf('Warning, attempting to access a non existing global variable called %s for entry %s\n',ValueXML,strFieldName);
        Value = DefaultValue; % assume a string?
    end
end

return;