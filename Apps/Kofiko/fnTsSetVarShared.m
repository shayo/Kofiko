function fnTsSetVarShared(strVarName, Value)
% Set the value of a shared paradigm variable 
% If variable does not exist, a new one will automatically be generated.
global g_strctSharedParadigmData

if ~isfield(g_strctSharedParadigmData, strVarName)
    g_strctSharedParadigmData = fnTsAddVar(g_strctSharedParadigmData, strVarName, Value, 1000); % Reasonable buffer size
end

fnTsSetVar(g_strctSharedParadigmData, strVarName, Value);

return;
