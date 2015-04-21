function acMedia = fnLoadMedia(hPTBWindow,astrctMedia, bShowProgressBar)
acMedia= cell(1, length(astrctMedia));
% Load media files!
if ~exist('bShowProgressBar','var')
    bShowProgressBar = false;
end;

for iFileIter=1:length(astrctMedia)
    if  astrctMedia(iFileIter).m_bImage
        acMedia{iFileIter}.m_bMovie = false;
        acMedia{iFileIter}.m_bAudio = false;
        acMedia{iFileIter}.m_bImage = true;
        I= fnReadImageWrapper(astrctMedia(iFileIter).m_strFileName);
        acMedia{iFileIter}.m_hHandle = Screen('MakeTexture', hPTBWindow,  I);
        acMedia{iFileIter}.m_iWidth = size(I,2);
        acMedia{iFileIter}.m_iHeight = size(I,1);
    elseif astrctMedia(iFileIter).m_bMovie
        acMedia{iFileIter}.m_bMovie = true;
        acMedia{iFileIter}.m_bAudio = false;
        acMedia{iFileIter}.m_bImage = false;
        [hMovie,fDuration,fFramesPerSeconds,iWidth,iHeight]=Screen('OpenMovie', hPTBWindow, astrctMedia(iFileIter).m_strFileName);
        acMedia{iFileIter}.m_iNumFrames = ceil(fDuration*fFramesPerSeconds);
        acMedia{iFileIter}.m_afMovieLengthSec(iFileIter) = fDuration;
        acMedia{iFileIter}.m_hHandle = hMovie;
        acMedia{iFileIter}.m_iWidth = iWidth;
        acMedia{iFileIter}.m_iHeight = iHeight;
    elseif astrctMedia(iFileIter).m_bAudio
        % Assume wav file, single channel ?
        acMedia{iFileIter}.m_bMovie = false;
        acMedia{iFileIter}.m_bAudio = true;
        acMedia{iFileIter}.m_bImage = false;
        [W, FS]= wavread( astrctMedia(iFileIter).m_strFileName);
        freq = 44100;
        if FS ~= freq
            W= resample(W, freq, FS);
            FS = freq;
        end;
        acMedia{iFileIter}.m_afAudioData = W;
         acMedia{iFileIter}.m_fSamplingRate = freq; % Conver on load to 44kHz
    end
    
    if bShowProgressBar && mod(iFileIter,10) == 0
        fnParadigmToKofikoComm('DisplayMessageNow',sprintf('Still Loading %d/%d',iFileIter,length(astrctMedia)));
    end
end

return;