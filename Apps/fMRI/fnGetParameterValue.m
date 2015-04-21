function Value = fnGetParameterValue(acParams, strParam)
Value  = [];
for k=1:length(acParams)
    if strcmpi(acParams{k}.Name ,strParam)
        Value  = acParams{k}.Value;
    end;
end
return;
