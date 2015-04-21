addpath('Z:\MEX\win32');
load('Z:\DebugForGrouping')
whos
a2iRegroupping = GroupChannelsToTetrode(afSortedTS,aiSortedCh, a2iTetrodeChannelTable);
a2iRegroupping' == a2fGroupEvents