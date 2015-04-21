function fnMaximizeWindow(hFigure)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

iNumTitle = get(hFigure,'NumberTitle');
strFigureName= get(hFigure,'Name');

strWindowName = ['maximize_',num2str(hFigure)];
set(hFigure,'Name',strWindowName,'NumberTitle','off');
drawnow; % Make sure this takes effect
fnMaximizeWind(strWindowName,get(hFigure),'Resize');

set(hFigure,'Name',strFigureName,'NumberTitle',iNumTitle);

return;
