function [a2cCharMatrix,acFileNamesNoPath] = fnStructToCharShort(acFileNamesWithPath) 
acFileNamesNoPath = fieldnames(acFileNamesWithPath);


a2cCharMatrix = char(acFileNamesNoPath);
return;
