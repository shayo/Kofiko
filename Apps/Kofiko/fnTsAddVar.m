function tstrct = fnTsAddVar(tstrct, strVarName, InitValue,iInitBufferLength)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% Timstamped structure
fCurrTime = GetSecs();

if ~exist('iInitBufferLength','var')
    iInitBufferLength = 1;
end;
% Allocate container.

if ischar(InitValue) || iscell(InitValue)
    Container = cell(1,iInitBufferLength);
    Container{1} = InitValue;

    afTimeStamp = zeros(1, iInitBufferLength);
    afTimeStamp(1) = fCurrTime;
    
    eval(['tstrct.',strVarName,'.Buffer = Container;']);
    eval(['tstrct.',strVarName,'.TimeStamp = afTimeStamp;']);
    eval(['tstrct.',strVarName,'.BufferIdx = 1;']);
    eval(['tstrct.',strVarName,'.BufferSize = iInitBufferLength;']);
    
else
    sz = size(InitValue);
    Container = zeros([sz, iInitBufferLength]);
    if length(sz) == 1
        Container(1) = InitValue;
    end;
    if length(sz) == 2
        Container(:,:,1) = InitValue;
    end;
    if length(sz) == 3
        Container(:,:,:,1) = InitValue;
    end;
    afTimeStamp = zeros(1, iInitBufferLength);
    afTimeStamp(1) = fCurrTime;
    tstrct = setfield(tstrct, strVarName, struct('Buffer', Container, 'TimeStamp', afTimeStamp,'BufferIdx',1,'BufferSize', iInitBufferLength));
    
end;

return;

