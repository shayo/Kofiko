function fnSetTableFromParams(hTable,acParams)
iNumParams = length(acParams);
abColumEditable = zeros(1,iNumParams)>0;
acRowNames = cell(1,iNumParams);
acRowData = cell(iNumParams,1);
for iParamIter=1:iNumParams 
    acRowNames{iParamIter} = acParams{iParamIter}.Name;
    acRowData{iParamIter} = acParams{iParamIter}.Value;
    abColumEditable(iParamIter) = true;
end
set(hTable,'Data', acRowData,...
            'ColumnName', {'Value'},...
           'ColumnFormat', {'char'},...
           'ColumnEditable', abColumEditable,...
            'RowName',acRowNames,'ColumnWidth',{425});
return;       