function strLogLine = fnStatCriticalLog(varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctWindows

strCurrentDateTime = datestr(now,'HH:MM:SS');
strInput = sprintf(varargin{:});
strLogLine = [strCurrentDateTime,' ',strInput];


if ishandle(g_strctWindows.m_strctSettingsPanel.m_hCriticalLog)
    acCurrLines = get(g_strctWindows.m_strctSettingsPanel.m_hCriticalLog,'string');
    acCurrLines = [acCurrLines;{strLogLine}];
    
    set(g_strctWindows.m_strctSettingsPanel.m_hCriticalLog,'string',acCurrLines,'value',length(acCurrLines));
end

return;
