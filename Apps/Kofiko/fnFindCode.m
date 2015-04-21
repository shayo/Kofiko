function iCode = fnFindCode(strCode)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm
for k=1:length(g_strctParadigm.m_aiAvailableCodes)
    if ~isempty( strfind(g_strctParadigm.m_acCodeDescription{g_strctParadigm.m_aiAvailableCodes(k)}, strCode))
        iCode = g_strctParadigm.m_aiAvailableCodes(k)-1; % Since the fist one is always zero
        return;
    end;
end;
iCode = -1;
return;