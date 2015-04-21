function acFilesNoPath = fnRemovePath(acFiles)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

acFilesNoPath = cell(size(acFiles));
for k=1:length(acFiles)
    [strDummy,acFilesNoPath{k}] = fileparts(acFiles{k});
end
return;

    
