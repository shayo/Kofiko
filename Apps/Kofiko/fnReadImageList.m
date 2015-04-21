function [acFileNames,abExist] = fnReadImageList(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
[strFolder, strFile] = fileparts(strImageList);
if strFolder(end) ~= '\'
    strFolder(end+1) = '\';
end

%iSlash = find(strImageList == '\' | strImageList == '/',1,'last');
%strFolder = strImageList(1:iSlash);
hFileID = fopen(strImageList);
if hFileID == -1
    acFilesNames = [];
    return;
end;
%strDummy = fgets(hFileID);
iEntry= 1;
while(1)
    strLine =  fgets(hFileID);
    if isempty(strLine)
        continue;
    end;
    if  strLine(1) == -1
        break;
    end;
    if ~isempty(strLine) && (strLine(end) == 10 || strLine(end) == 13)
        strLine = strLine(1:end-1);
    end;
    if ~isempty(strLine) && (strLine(end) == 10 || strLine(end) == 13)
        strLine = strLine(1:end-1);
    end;
    if isempty(strLine)
       continue;
    end;
  
    acFileNames{iEntry} = [strFolder,strLine];
    abExist(iEntry) = exist(acFileNames{iEntry},'file') > 0;
    %if ~abExist(iEntry)
        %fprintf('%s is missing\n',acFileNames{iEntry});
    %end
    iEntry = iEntry + 1;
end;

if ~abExist(1) 
    [strPath,strFile] = fileparts(acFileNames{1});
    if ~isempty(str2num(strFile))
        % RF-3 style list...
        % Do not warn about this missing file....
        acFileNames = acFileNames(2:end);
        abExist = abExist(2:end);
    end;
end

fclose(hFileID);

return;
