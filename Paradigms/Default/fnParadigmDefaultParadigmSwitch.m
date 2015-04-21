function fnParadigmDefaultParadigmSwitch(strEvent)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% No initialization needed for this dummy paradigm...
global g_strctPTB g_strctParadigm
switch strEvent
    case 'Init'
        g_strctParadigm.m_hTexture = Screen('MakeTexture', g_strctPTB.m_hWindow,  g_strctParadigm.m_a3fKofikoLogo);
    case 'Close'
        Screen('Close',g_strctParadigm.m_hTexture);           
end
return;
