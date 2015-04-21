function acFileNames = fnInitializeTextures(strImageList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm

% Generate PTB handles for fast drawing.
% if isfield(g_strctPTB,'m_ahTextures')
%     % Close existing textures.
%     for k=find(g_strctPTB.m_ahTextures>0)
%         Screen('Close',g_strctPTB.m_ahTextures(k));
%     end;
%     g_strctPTB.m_ahTextures = [];
%     g_strctPTB.m_a2iTextureSize = [];
% end;

[acFileNames] = fnReadImageList(strImageList);
fnKofikoClearTextureMemory();
[g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,g_strctParadigm.m_abIsMovie,...
    g_strctParadigm.m_afMovieLengthSec] = fnInitializeTexturesAux(acFileNames);

return;
