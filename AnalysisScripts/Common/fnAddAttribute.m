function strctOut = fnAddAttribute(strctIn, strField, strValue, cActualValue)
if ~exist('cActualValue','var')
    cActualValue = [];
end

if isfield(strctIn,'m_a2cAttributes')
    a2cAttributes = getfield(strctIn,'m_a2cAttributes');
    
    bAlreadyExist = ismember(strField, a2cAttributes(1,:) );
    if ~bAlreadyExist
        iNewEntry = size(a2cAttributes,2) + 1;
        a2cAttributes{1,iNewEntry} = strField;
        a2cAttributes{2,iNewEntry} = strValue;
        a2cAttributes{3,iNewEntry} = cActualValue;
    else
        % Exist. Warn and just update...
        fnWorkerLog('Warning. Field %s already exists in strctUnit. Updating instead of adding.',strField);
        iIndex = find(ismember(a2cAttributes(1,:) ,strField),1,'first');
        a2cAttributes{1,iIndex} = strField;
        a2cAttributes{2,iIndex} = strValue;
        a2cAttributes{3,iIndex} = cActualValue;
     
    end
else
    a2cAttributes = cell(3,1);
    a2cAttributes{1,1} = strField;
    a2cAttributes{2,1} = strValue;
    a2cAttributes{3,1} = cActualValue;
end
strctOut = setfield(strctIn,'m_a2cAttributes',a2cAttributes);

return;
