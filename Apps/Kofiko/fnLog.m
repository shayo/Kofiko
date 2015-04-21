function strLogLine = fnLog(varargin) 
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_hLogFileID g_bVERBOSE g_bLastLoggedList g_strctLog

strCurrentDateTime = datestr(now,'dd-mmm-yyyy HH:MM:SS:FFF');
strInput = sprintf(varargin{:});
strLogLine = [strCurrentDateTime,' ',strInput];
g_bLastLoggedList = strLogLine;

if g_bVERBOSE
    fprintf('%s\n',strLogLine);
end;

if ~isempty(g_strctLog)
    
    iLastEntry = g_strctLog.Log.BufferIdx;
    if iLastEntry+1 > g_strctLog.Log.BufferSize
        g_strctLog.Log = fnIncreaseBufferSize(g_strctLog.Log);
    end;
    g_strctLog.Log.Buffer{iLastEntry+1} = strInput;
    g_strctLog.Log.TimeStamp(iLastEntry+1) = GetSecs();
    g_strctLog.Log.BufferIdx = iLastEntry+1;
    
    
    if ~isempty(g_hLogFileID)
        fwrite(g_hLogFileID, [strLogLine,13,10]);
    end;
end
return;
