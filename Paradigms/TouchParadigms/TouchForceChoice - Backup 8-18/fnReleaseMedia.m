function fnReleaseMedia(acMedia)
% Load media files!
for iFileIter=1:length(acMedia)
    if acMedia{iFileIter}.m_bMovie 
        % Movie
        Screen('CloseMovie', acMedia{iFileIter}.m_hHandle);
    elseif acMedia{iFileIter}.m_bImage
        % Image
        Screen('Close', acMedia{iFileIter}.m_hHandle);
    end
end

return;