function fnParadigmFiveDotParadigmSwitch(strEvent)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm

switch strEvent
    case 'Init'
        fnParadigmToKofikoComm('SetFixationPosition',...
            g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx));
    case 'Close'
end
return;
