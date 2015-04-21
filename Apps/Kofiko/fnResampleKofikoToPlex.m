function Values = fnResampleKofikoToPlex(strctTsVar, afPlexonTime, strctSession)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


try
    iStart = find(strctTsVar.TimeStamp <= strctSession.m_fKofikoStartTS,1,'last');

    % 07/Apr/2011 Change
    % If we started recording, and only then switched a paradigm for the
    % first time, there might not be a timetamp before start record event.
    % In this case, we later discard all values before that time stamp.
    
    if 0 %isempty(iStart)
        % No timestamp information is available for this session.
        % Value was probably initialized at startup and was not changed throughout the experiment...
        iIndex = find(strctTsVar.TimeStamp  <= strctSession.m_fKofikoStartTS,1,'last');
        if isempty(iIndex)
            iIndex = 1;
            
        end
        
        if length(strctTsVar.TimeStamp) == 1
            strctTsVar.Buffer = strctTsVar.Buffer';
        end
        
        iDim = size(strctTsVar.Buffer,2);

        Values = zeros( length(afPlexonTime), iDim);
        for iIter=1:iDim
            Values(:,iIter) = strctTsVar.Buffer(iIndex,iIter);
        end;
        
    else
        iEnd = find(strctTsVar.TimeStamp >= strctSession.m_fKofikoEndTS,1,'first');
        if isempty(iEnd)
            iEnd = length(strctTsVar.TimeStamp);
        end;
        
        if isempty(iStart)
            iStart = 1;
        end
            
        aiInterval = iStart:iEnd;
        
        % Convert strctTsVar (kofiko timestamp) to plexon timestamp
        afKofikoInPlexTime = fnKofikoTimeToPlexonTime(strctSession,strctTsVar.TimeStamp(aiInterval));
        
        
        fFirstTS_Plexon = afKofikoInPlexTime(1);
        abInvalid = afPlexonTime<fFirstTS_Plexon;
        
%         afTimeRelative = strctTsVar.TimeStamp(aiInterval) - strctSession.m_fKofikoStartTS;
%         afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%             afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%             strctSession.m_afKofikoTStoPlexonTS(1);
        
        if length(strctTsVar.TimeStamp) == 1
            strctTsVar.Buffer = strctTsVar.Buffer';
        end
        iDim = size(strctTsVar.Buffer,2);
        
        
        Values = zeros( length(afPlexonTime), iDim);
        for iDimIter=1:iDim
            Values(:,iDimIter) = fnMyInterp1(afKofikoInPlexTime, squeeze(strctTsVar.Buffer(aiInterval,iDimIter)), afPlexonTime);
            Values(abInvalid,iDimIter) = NaN;
        end;
    end;
catch
    Values = fnResampleKofikoToPlexOLD(strctTsVar, afPlexonTime, strctSession) ;
end





return;



function Values = fnResampleKofikoToPlexOLD(strctTsVar, afPlexonTime, strctSession)
iStart = find(strctTsVar.TimeStamp <= strctSession.m_fKofikoStartTS,1,'last');

if isempty(iStart)
    % No timestamp information is available for this session.
    % Value was probably initialized at startup and was not changed throughout the experiment...
    iIndex = find(strctTsVar.TimeStamp  <= strctSession.m_fKofikoStartTS,1,'last');
    iDim = size(strctTsVar.Buffer,2);
    if iDim > 2
        iDim = size(strctTsVar.Buffer,1);
    end;
    Values = zeros( length(afPlexonTime), iDim);
    if iDim == 1
        Values(:) = strctTsVar.Buffer(iIndex);
    else
        for iIter=1:iDim
            Values(:,iIter) = strctTsVar.Buffer(iDim,iIndex);
        end;
    end;
    
else
    iEnd = find(strctTsVar.TimeStamp >= strctSession.m_fKofikoEndTS,1,'first');
    if isempty(iEnd)
        iEnd = length(strctTsVar.TimeStamp);
    end;
    aiInterval = iStart:iEnd;
    
    % Convert strctTsVar (kofiko timestamp) to plexon timestamp
            afKofikoInPlexTime = fnKofikoTimeToPlexonTime(strctSession,strctTsVar.TimeStamp(aiInterval));
% 
%     afTimeRelative = strctTsVar.TimeStamp(aiInterval) - strctSession.m_fKofikoStartTS;
%     afKofikoInPlexTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
%         afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
%         strctSession.m_afKofikoTStoPlexonTS(1);
    
    iDim = size(strctTsVar.Buffer,1);
    if iDim > 2
        strctTsVar.Buffer= strctTsVar.Buffer';
        iDim = size(strctTsVar.Buffer,1);
    end;
    
    Values = zeros( length(afPlexonTime), iDim);
    for iDimIter=1:iDim
        Values(:,iDimIter) = fnMyInterp1(afKofikoInPlexTime, squeeze(strctTsVar.Buffer(iDimIter,aiInterval)), afPlexonTime);
    end;
end;






return;

