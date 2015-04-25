function fnParadigmPassiveCleanTextureMemory()
global  g_strctParadigm
if isfield(g_strctParadigm,'m_strctTexturesBuffer') && ~isempty(g_strctParadigm.m_strctTexturesBuffer) && isfield(g_strctParadigm.m_strctTexturesBuffer,'m_ahHandles') && ...
        ~isempty(g_strctParadigm.m_strctTexturesBuffer.m_ahHandles)
    abIsMovie = g_strctParadigm.m_strctTexturesBuffer.m_abIsMovie;
    aiMovieHandles = find(abIsMovie);
    for k=1:length(aiMovieHandles)
        Screen('CloseMovie', g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(aiMovieHandles(k)));
    end

    Screen('Close',g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(~abIsMovie));
    g_strctParadigm.m_strctTexturesBuffer = [];
end

return;
