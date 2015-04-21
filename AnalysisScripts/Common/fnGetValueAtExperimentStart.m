function Value = fnGetValueAtExperimentStart(strctTsVar, fTimestamp)
iIndex = find(strctTsVar.TimeStamp <= fTimestamp,1,'last');
if isempty(iIndex)
    Value = [];
else
    if iscell(strctTsVar.Buffer)
        Value = strctTsVar.Buffer{iIndex};
    else
        Value = strctTsVar.Buffer(iIndex,:);
    end
end
return;

