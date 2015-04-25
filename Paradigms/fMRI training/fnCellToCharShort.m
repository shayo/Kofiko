function [a2cCharMatrix,acFileNamesNoPath] = fnCellToCharShort(acFileNamesWithPath)
iNumFileNames = length(acFileNamesWithPath);
acFileNamesNoPath = cell(1,iNumFileNames);
for k=1:iNumFileNames
    [strPath, strFileName] = fileparts(acFileNamesWithPath{k});
    acFileNamesNoPath{k} = strFileName;
end

a2cCharMatrix = char(acFileNamesNoPath);
return;

