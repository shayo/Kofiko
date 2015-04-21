function tstrct = fnTsSetVar(tstrct, strVarName, Value)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Timstamped structure
if nargout == 0
    error('You forgot the left field');
end;

fCurrTime = GetSecs();
%eval(['iLastEntry = tstrct.',strVarName,'.BufferIdx;']);

%f = tstrct.(deblank(strVarName)); % deblank field name        

iLastEntry = getfield(getfield(tstrct,strVarName),'BufferIdx');
Buf = getfield(getfield(tstrct,strVarName),'Buffer');    
sz = size(Buf);
iBufferLength = sz(end);

if iLastEntry+1 > iBufferLength
    % Reallocate buffer (don't forget to realloc timestamp as well)
    iNewBufferLength = 2*iBufferLength;

    CurrVar = getfield(tstrct,strVarName);
    OLD_Buf = getfield(CurrVar,'Buffer');
    OLD_TS = getfield(CurrVar,'TimeStamp');
    
    if iscell(Buf) %ischar(Value) || iscell(Value)
        Buf = cell(1,iNewBufferLength);
        Buf(1:iLastEntry) = OLD_Buf;
        TS = zeros(1, iNewBufferLength);
        TS(1:iLastEntry) = OLD_TS;
    else
        sz(end) = iNewBufferLength;
        Buf = zeros(sz);
        if length(sz) == 3
            Buf(:,:,1:iLastEntry) = OLD_Buf;
        end;
        TS = zeros(1, iNewBufferLength);
        TS(1:iLastEntry) = OLD_TS;
        
    end;
else
    CurrVar = getfield(tstrct,strVarName);
    Buf = getfield(CurrVar,'Buffer');
    TS = getfield(CurrVar,'TimeStamp');
end


if iscell(Buf) %ischar(Value) || iscell(Value)
        Buf{iLastEntry+1} = Value;
        TS(iLastEntry+1) = fCurrTime;
        eval(['tstrct.',strVarName,'.Buffer = Buf;']);
        eval(['tstrct.',strVarName,'.TimeStamp = TS;']);
        eval(['tstrct.',strVarName,'.BufferIdx = iLastEntry+1;']);
else
    if length(sz) == 3
        Buf(:,:,iLastEntry+1) = Value;
        TS(iLastEntry+1) = fCurrTime;
        tstrct = setfield(tstrct, strVarName, struct('Buffer', Buf, 'TimeStamp', TS,'BufferIdx',iLastEntry+1));
    end;
end;

return;

