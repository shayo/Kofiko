function [aiGroup, afWeights, acFileNames, acFileNamesNoPath] = fnReadWeightedImageList(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
[strFolder, strFile] = fileparts(strImageList);
if strFolder(end) ~= '\'
    strFolder(end+1) = '\';
end

hFileID = fopen(strImageList);
acData = textscan(hFileID,'%d %f %s');
fclose(hFileID);

aiGroup = double(acData{1}');
afWeights = double(acData{2}');
acFileNames = acData{3};
iNumFiles = length(acFileNames);
abExist = zeros(1,iNumFiles);
acFileNamesNoPath  = cell(1,iNumFiles);
for k=1:iNumFiles
    strFullFileName = [strFolder, acFileNames{k}];
    [strPath,strFile]=fileparts(strFullFileName);
    acFileNamesNoPath{k} = strFile;
    acFileNames{k} = strFullFileName;
    abExist(k) = exist(strFullFileName,'file');
end

if sum(~abExist) > 0
    % Some of the files are missing...
    fprintf('WARNING, some of the files are missing!\n');
    aiMissing = find(~abExist);
    for k=1:length(aiMissing)
        fprintf('%s\n',acFileNames{aiMissing(k)});
    end
    fnHidePTB();
    WaitSecs(0.1);
    fnShowPTB();
    acFileNames = acFileNames(abExist);
    acFileNamesNoPath = acFileNamesNoPath(abExist); 
    afWeights = afWeights(abExist);
end

return;
