function fnStimulusServerClearTextureMemory()
global  g_strctDraw
if isfield(g_strctDraw,'m_ahHandles') && ~isempty(g_strctDraw.m_ahHandles)
    aiMovieHandles = find(g_strctDraw.m_abIsMovie);
    for k=1:length(aiMovieHandles)
        Screen('CloseMovie', g_strctDraw.m_ahHandles(aiMovieHandles(k)));
    end
    Screen('Close',g_strctDraw.m_ahHandles(~g_strctDraw.m_abIsMovie));
    g_strctDraw.m_ahHandles = [];
    g_strctDraw.m_abIsMovie = [];
end

return;
