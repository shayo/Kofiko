function [bExist, strValue, Value] = fnFindAttribute(a2cAttributes, strField)
strValue = [];
Value = [];
bExist = false;
for k=1:size(a2cAttributes,2)
    if strcmpi(a2cAttributes{1,k},strField)
        strValue = a2cAttributes{2,k};
        Value = a2cAttributes{3,k};
        bExist = true;
        return;
    end
end

return;
