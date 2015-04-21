function [hPanel,iHeight, iPanelWidth] = fnCreateParadigmSubPanel(hParentPanel,iStartY,iEndY,strTitle)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
ahParentPos = get(hParentPanel,'Position');
iPanelWidth =  ahParentPos(3)-15;

iHeight = iEndY-iStartY;
hPanel = uipanel('Units','Pixels','Position',...
    [5, ahParentPos(4)-iHeight-iStartY , ...
    ahParentPos(3)-10 iEndY-iStartY],'parent',hParentPanel,'Title', strTitle);

return;
