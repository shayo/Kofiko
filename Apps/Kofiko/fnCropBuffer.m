function strctOut = fnCropBuffer(strctIn)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

if iscell(strctIn)
    for k=1:length(strctIn)
        if isempty(strctIn{k})
            strctOut{k} = [];
        else
            strctOut{k} = fnCropBuffer(strctIn{k});
        end;
    end

elseif isstruct(strctIn)
    if length(strctIn) == 1

        acFields = fieldnames(strctIn);
        strctOut = strctIn;
        for k=1:length(acFields)
            strctInside = getfield(strctIn, acFields{k});
            if isstruct(strctInside) && isfield(strctInside,'Buffer')
                try
                    for iIter=1:length(strctInside)

                        if iscell(strctInside(iIter).Buffer)
                            strctInside(iIter).Buffer = strctInside(iIter).Buffer(1:strctInside.BufferIdx);
                        else
                            if size(strctInside(iIter).Buffer,2) > 1
                                strctInside(iIter).Buffer = squeeze(strctInside(iIter).Buffer(:,:,1:strctInside(iIter).BufferIdx))';
                            else

                                strctInside(iIter).Buffer = squeeze(strctInside(iIter).Buffer(:,:,1:strctInside(iIter).BufferIdx));
                            end;

                        end;
                        strctInside(iIter).TimeStamp = strctInside(iIter).TimeStamp(1:strctInside(iIter).BufferIdx);
                    end


                    if isfield(strctInside,'BufferSize')
                        strctInside = rmfield(strctInside,'BufferSize');
                    end;
                    if isfield(strctInside,'BufferIdx')
                        strctInside = rmfield(strctInside,'BufferIdx');
                    end

                catch
                    fprintf('Failed to crop %s \n',acFields{k});
                end

                strctOut = setfield(strctOut, acFields{k}, strctInside );
            elseif isstruct(strctInside) || iscell(strctInside)
                % Recursive...
                if isempty(strctInside)
                    strctOut = setfield(strctOut,acFields{k},[]);
                else
                    strctOut = setfield(strctOut, acFields{k}, fnCropBuffer(strctInside));
                end
            end;
        end;
    else
        for q=1:length(strctIn)
            strctOut(q) = fnCropBuffer(strctIn(q));
        end;
    end


else
    strctOut = strctIn;
end;
return;
