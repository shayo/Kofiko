function [acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

[aiIndex acNames] = textread(strImageList,'%d %s');
[strPath,strFile] = fileparts(strImageList);
iNumImages = length(acNames);
assert( all( sort(aiIndex)' == 1:iNumImages ))

acFileNames = cell(1,iNumImages);
acFileNamesNoPath = cell(1,iNumImages);
abExist = zeros(1,iNumImages) > 0;
for k=1:iNumImages
    acFileNames{k} = [strPath,'\',acNames{aiIndex(k)}];
    [strDummy,acFileNamesNoPath{k}]=fileparts(acFileNames{k});
    abExist(k) = exist(acFileNames{k},'file') > 0;
end

assert(all(abExist));

return;