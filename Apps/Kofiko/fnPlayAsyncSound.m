function fnPlayAsyncSound(strSoundName)
global g_strctSoundMedia
if ~isfield(g_strctSoundMedia,'m_acSounds') || isempty(g_strctSoundMedia.m_acSounds)
    % Cannot play file!
    fprintf('*** Cannot play %s\n', strSoundName);
    return;
end;

for iSoundsIter=1:length(g_strctSoundMedia.m_acSounds)
    if strcmpi(g_strctSoundMedia.m_acSounds{iSoundsIter}.m_strName,strSoundName);
       %play(g_strctSoundMedia.m_acSounds{iSoundsIter}.m_hHandle);
       wavplay(g_strctSoundMedia.m_acSounds{iSoundsIter}.m_afData,g_strctSoundMedia.m_acSounds{iSoundsIter}.m_fSamplingRate,'async')
       return;
    end
end
    
return;
