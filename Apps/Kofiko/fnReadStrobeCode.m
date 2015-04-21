function [acCodeDescription, aiAvailbleCodes] = fnReadStrobeCode(strFileName)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumCodes = 2^15;
acCodeDescription = cell(1, iNumCodes);
hFileID = fopen(strFileName,'r');
if (hFileID == -1)
    error(sprintf('Error loading strobe file %s\n',strFileName));
end;

abCode = zeros(1, iNumCodes);
iLineCounter = 0;
while 1
    strLine = fgetl(hFileID);
    iLineCounter = iLineCounter + 1;
    if ~ischar(strLine) 
        break
    end
    if isempty(strLine) || strLine(1) == '#'
        continue;
    end;
    
    strOrigLine = strLine;
    while strLine(1) == ' '
        strLine = strLine(2:end);
    end;
    
    iFirstSpace = find(strLine == ' ',1,'first');
    if isempty(iFirstSpace)
        fprintf('Error parsing line %d from %s : %s\n', iLineCounter, strFileName, strOrigLine);
    end;
    
    iIndex = str2num(strLine(1:iFirstSpace-1));
    strDescription = strLine(iFirstSpace+1:end);
    
    if abCode(iIndex+1) == 1
        fprintf('Error parsing %s at line %d. Code %d was already defined\n', strFileName, iLineCounter, iIndex);
    end;
    
    abCode(iIndex+1) = 1;
    acCodeDescription{iIndex+1} = strDescription;
end

fclose(hFileID);


aiAvailbleCodes = find(abCode);


