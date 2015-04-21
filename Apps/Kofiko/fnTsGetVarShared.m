function [Value, bDoesNotExist] = fnTsGetVarShared(strVarName)
% Set the value of a shared paradigm variable 
% If variable does not exist, a new one will automatically be generated.
global g_strctSharedParadigmData

bDoesNotExist = false;
if ~isfield(g_strctSharedParadigmData, strVarName)
    bDoesNotExist = true;
    Value = [];
    return;
end

Value = fnTsGetVar(g_strctSharedParadigmData, strVarName);

return;
