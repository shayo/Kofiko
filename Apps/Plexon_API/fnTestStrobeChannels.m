function [error] = fnTestStrobeChannels()
global g_strctPlexon

fnGetSpikesFromPlexon();

for i = 1:15
fnDAQNI('StrobeWord',i^2);



end
fnGetSpikesFromPlexon();


if 




end


return;