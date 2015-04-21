function acSounds = fnLoadSoundsAux(acSoundFileNames,acSoundNames)
iNumSounds = length(acSoundFileNames);
acSounds  = cell(1,iNumSounds);
for iFileIter=1:iNumSounds
    strctSound.m_strName = acSoundNames{iFileIter};
    strctSound.m_strFileName = acSoundFileNames{iFileIter};
    [strctSound.m_afData,strctSound.m_fSamplingRate] = wavread(acSoundFileNames{iFileIter});
%    strctSound.m_hHandle = audioplayer(strctSound.m_afData, strctSound.m_fSamplingRate);
    acSounds{iFileIter} = strctSound;
end

return;


