function fnKofikoClearTextureMemory()
global  g_strctParadigm
if isfield(g_strctParadigm,'m_ahHandles') && ~isempty(g_strctParadigm.m_ahHandles) && isfield(g_strctParadigm,'m_strctDesign') && ...
    ~isempty(g_strctParadigm.m_strctDesign) 
    abIsMovie = cat(1,g_strctParadigm.m_strctDesign.m_astrctMedia.m_bMovie);
    aiMovieHandles = find(abIsMovie);
    for k=1:length(aiMovieHandles)
        Screen('CloseMovie', g_strctParadigm.m_ahHandles(aiMovieHandles(k)));
    end
    Screen('Close',g_strctParadigm.m_ahHandles(~abIsMovie));
    g_strctParadigm.m_ahHandles = [];
end

return;
