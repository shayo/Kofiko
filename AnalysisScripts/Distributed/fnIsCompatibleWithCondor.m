function bCompatible = fnIsCompatibleWithCondor(strPath,strSession)
astrctRedundantPlexFiles=dir([strPath,strSession,'*_spl*.plx']);
bCompatible = isempty(astrctRedundantPlexFiles);
return;
