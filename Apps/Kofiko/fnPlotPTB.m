function afAxis = fnPlotPTB(afX, afY, aiRect, afColor, afAxis)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctPTB
if ~exist('afAxis','var')
    % Auto scaling
    afAxis = [min(afX)-eps max(afX)+eps min(afY)-eps max(afY)+eps];
end

afXpix = (afX - afAxis(1) ) / (afAxis(2)-afAxis(1)) * (aiRect(3)-aiRect(1)-2)  + aiRect(1)+1;
afYpix = aiRect(4)-1 - (afY - afAxis(3) ) / (afAxis(4)-afAxis(3)) * (aiRect(4)-aiRect(2)-2);
a2iRect = [afXpix, fliplr(afXpix); afYpix, fliplr(afYpix)];
Screen('FramePoly',g_strctPTB.m_hWindow, afColor,a2iRect');
Screen('FrameRect',g_strctPTB.m_hWindow, [0 0 255],aiRect);
Screen('DrawText', g_strctPTB.m_hWindow, num2str(round(max(afY))), aiRect(3)+30, aiRect(2)-15,afColor);
Screen('DrawText', g_strctPTB.m_hWindow, num2str(round(min(afY))), aiRect(3)+30, aiRect(4)-15,afColor);
return;