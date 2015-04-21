function acUnitsStat = fnCollectPassiveFixationUnitStats(strctKofiko, strctPlexon, strctSession,iExperimentIndex, strctConfig)
% Computes various statistics about the recorded units in a given recorded session
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

if isempty(strctSession)
    % Collect behavioral data 
    fnWorkerLog('Behavioral data analysis for passive fixation during the ENTIRE experiment is not yet implemented.');
    acUnitsStat = [];
    return;
end
iParadigmIndex = fnFindParadigmIndex(strctKofiko,'Passive Fixation');
assert(iParadigmIndex~=-1);
acUnitsStat = fnCollectPassiveFixationUnitStatsAuxMultList(strctKofiko, strctPlexon, strctSession,iExperimentIndex, strctConfig,iParadigmIndex);
return;
