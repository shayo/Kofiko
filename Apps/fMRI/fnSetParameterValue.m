function acParams = fnSetParameterValue(acParams, strParam, Value)
for k=1:length(acParams)
    if strcmpi(acParams{k}.Name ,strParam)
        acParams{k}.Value = Value;
        return;
    end;
end
% Not found, just add it
iNumParam = length(acParams);
acParams{iNumParam+1}.Name = strParam;
acParams{iNumParam+1}.Value = Value;

return;
