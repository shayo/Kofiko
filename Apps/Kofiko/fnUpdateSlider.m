function fnUpdateSlider(hHandle, fValue)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Wrapper that makes sure values are always in range...
fMax = get(hHandle,'max');
fMin = get(hHandle,'min');
set(hHandle,'value',fValue,'max', max(fMax,fValue), 'min',min(fMin,fValue));
return;
