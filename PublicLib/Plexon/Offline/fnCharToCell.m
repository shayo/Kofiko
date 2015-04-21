function acArray=fnCharToCell(a2charMatrix)
iNumEntries = size(a2charMatrix,1);
acArray = cell(1,iNumEntries);
for k=1:iNumEntries
    iEndIndex = find(a2charMatrix(k,:)~= 0,1,'last');
    acArray{k} = a2charMatrix(k,1:iEndIndex);
end;
