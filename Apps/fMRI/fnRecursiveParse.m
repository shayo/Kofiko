function strctData = fnRecursiveParse(strctXML,strctData)
iNumKids = length(strctXML.Children);
if iNumKids == 1
    % stop
    strctData = setfield(strctData, strctXML.Name, strctXML.Children.Data);
    return;
end

for iKidIter=1:iNumKids
   strctData = fnRecursiveParse(strctXML.Children(iKidIter),strctData);
end

return;
