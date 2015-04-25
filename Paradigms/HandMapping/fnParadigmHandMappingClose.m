function [strctOutput] = fnParadigm16BitsClose()

% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctPlexon
% Do not save these variables....
g_strctParadigm.m_a3fRandPatterns = [];
 fnParadigmHandMappingCleanTextureMemory();
 
 try
	PL_Close(g_strctPlexon.m_iServerID);
end
 fnCreateExperimentBackup(g_strctParadigm, 'Final');
 return;