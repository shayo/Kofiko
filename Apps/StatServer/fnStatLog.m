function strLogLine = fnStatLog(varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctWindows

strCurrentDateTime = datestr(now,'dd-mmm-yyyy HH:MM:SS:FFF');
strInput = sprintf(varargin{:});
strLogLine = [strCurrentDateTime,' ',strInput];

if ishandle(g_strctWindows.m_strctSettingsPanel.m_hLogTextBox)
    acCurrLines = get(g_strctWindows.m_strctSettingsPanel.m_hLogTextBox,'string');
    NumLines = 14;
    if length(acCurrLines) >= NumLines
        acCurrLines = [acCurrLines(2:NumLines);{strLogLine}];
    else
        acCurrLines = [acCurrLines;{strLogLine}];
    end
    
    set(g_strctWindows.m_strctSettingsPanel.m_hLogTextBox,'string',acCurrLines);
end

return;
