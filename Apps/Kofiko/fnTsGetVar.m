function Value = fnTsGetVar(tstrct, strVarName)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

eval(['iLastEntry = tstrct.',strVarName,'.BufferIdx;']);
eval(['Buf = tstrct.',strVarName,'.Buffer;']);
sz = size(Buf);
if ischar(Buf) || iscell(Buf)
   Value = Buf{iLastEntry};
else
    if length(sz) == 3
        Value = Buf(:,:,iLastEntry);
    end;
end;

return;
