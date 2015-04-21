function bSuccessful  = fnStartLogFileWithKnownFileName(strLogFileName,strSubjectName)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_hLogFileID g_strLogFileName g_strctLog

g_strLogFileName = strLogFileName;
[strLogFolder,strFile] = fileparts(strLogFileName);
if strLogFolder(end) ~= '\'
    strLogFolder(end+1) = '\';
end;
if ~exist(strLogFolder,'dir')
    mkdir(strLogFolder);
end;

g_strctLog = fnTsAddVar([],'Log', ['Starting log for subject ',strSubjectName],10000);
g_hLogFileID = fopen(g_strLogFileName,'w+');
bSuccessful = g_hLogFileID ~= -1;
return;