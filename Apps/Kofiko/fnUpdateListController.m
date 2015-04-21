function fnUpdateListController(hController, acNames, aiSelected, bMultipleSelect)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% strList = '';
% for k=1:length(acNames)
%     strList = [strList,'|',acNames{k}];
% end
if isempty(aiSelected)
    aiSelected = 1;
end;

if bMultipleSelect
    iMax = length(acNames);
else
    iMax = 1;
end
set(hController,'string',char(acNames),'value',aiSelected,'min',1,'max',iMax);

return;

