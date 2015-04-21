function fnResetStat(strWhatToReset)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctCycle g_strctParadigm g_handles g_strctDAQParams g_strctGUIParams

if ~exist('strWhatToReset','var')
    strWhatToReset = 'AllChannels';
end;

g_strctCycle.m_strctStatistics.m_iTrialType= 0;


return;
