function fnParadigmDefaultDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctPTB g_strctParadigm

Screen('FillRect',g_strctPTB.m_hWindow,0);

Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_hTexture,[],[], 0);


return;
