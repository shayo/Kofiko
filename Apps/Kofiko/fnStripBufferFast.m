function strctOut = fnStripBufferFast(strctIn)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

acFields = fieldnames(strctIn);
strctOut = strctIn;
for k=1:length(acFields)
    strctInside = getfield(strctIn, acFields{k});
    if isstruct(strctInside) && isfield(strctInside,'Buffer')
        Value = fnTsGetVar(strctIn, acFields{k});
        strctOut = setfield(strctOut, acFields{k}, Value );
    end;
end;