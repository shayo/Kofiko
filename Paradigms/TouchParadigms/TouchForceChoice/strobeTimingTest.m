function strobeTimingTest()
fnDAQNI('Init',0)


pause()
for i = 1:15
tic
fnDAQNI('StrobeWord',(2^i) - 1);
toc;

end


return;