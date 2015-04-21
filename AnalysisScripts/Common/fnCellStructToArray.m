function Array = fnCellStructToArray(acStructArray, strField)
if isempty(acStructArray)
    Array = {};
    return;
end;
Field = getfield(acStructArray{1},strField);
iNumCells = length(acStructArray);
switch class(Field)
    case 'double'
        Array = zeros(1,iNumCells);
        for k=1:iNumCells
            if isfield(acStructArray{k},strField);
                Array(k) = getfield(acStructArray{k},strField);
            else
                Array(k) = NaN;
            end
        end
    case 'struct'
        Array = cell(1,iNumCells);
         for k=1:iNumCells
            Array{k} = getfield(acStructArray{k},strField);
        end
                
    case 'char'
      Array = cell(1,iNumCells);
        for k=1:iNumCells
            Array{k} = getfield(acStructArray{k},strField);
        end
         
end
return;



