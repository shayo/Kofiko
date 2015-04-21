function fnJuiceOn()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctCycle g_strctDAQParams g_strctSystemCodes
g_strctCycle.m_strctJuiceProcess.m_fParadigmRewardTimer = GetSecs();
fnDAQWrapper('SetBit',g_strctDAQParams.m_fJuicePort, 1);
fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iJuiceON);
g_strctDAQParams=fnTsSetVar(g_strctDAQParams,'JuiceRewards',{g_strctCycle.m_strctJuiceProcess});
g_strctCycle.m_bValveOpen = 1;

return;
