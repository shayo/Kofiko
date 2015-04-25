function k=fnFindString(acCell, strSearch)
for k=1:length(acCell)
    if strcmpi(acCell{k}, strSearch)
        return;
    end
end
k=-1;
return;