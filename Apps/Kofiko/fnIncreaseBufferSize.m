function X=fnIncreaseBufferSize(X)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

OLD_Buf = X.Buffer;
OLD_TS = X.TimeStamp;
sz = size(OLD_Buf);
iNewBufferSize = 2*length(OLD_TS);
sz(end) = iNewBufferSize;
if iscell(OLD_Buf)
    X.Buffer = cell(sz);
    X.Buffer(1:X.BufferIdx) = OLD_Buf;
else
    X.Buffer = zeros(sz);
    X.Buffer(:,:,1:X.BufferIdx) = OLD_Buf;
end;
X.TimeStamp = zeros(1,iNewBufferSize);
X.TimeStamp(1:X.BufferIdx) = OLD_TS;
X.BufferSize = iNewBufferSize;
return;

