function fnJuiceOff()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctCycle g_strctDAQParams g_strctSystemCodes
fnDAQWrapper('SetBit',g_strctDAQParams.m_fJuicePort, 0);
fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iJuiceOFF);
g_strctCycle.m_bValveOpen = 0;

return;
