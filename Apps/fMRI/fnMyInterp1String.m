function strValue = fnMyInterp1String(strctTsVar, fTimeStamp)
iIndex = find(strctTsVar.TimeStamp <= fTimeStamp,1,'last');
strValue = [];
if ~isempty(iIndex)
    strValue = strctTsVar.Buffer{iIndex};
end
return;
