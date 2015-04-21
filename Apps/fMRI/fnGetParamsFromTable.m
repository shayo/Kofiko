function acParams = fnGetParamsFromTable(hParamTable)
Data = get(hParamTable,'Data');
RowName = get(hParamTable,'RowName');
iNumParams = size(Data,1);

for k=1:iNumParams
   acParams{k}.Name = RowName{k};
   acParams{k}.Value = Data{k};
end
return;
