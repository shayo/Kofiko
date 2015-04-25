function fnTestStimulation



fnDAQNI('Init',0);

for i = 1:60
    i
    tic
fnDAQNI('SetBit',4, 1);
delay(.25*1e-3);
fnDAQNI('SetBit', 4, 0);
toc
tic
delay(.1*1e-3);
toc
tic
fnDAQNI('SetBit', 4, 1);
delay(.15*1e-3);
fnDAQNI('SetBit', 4, 0);
toc
end



return;



function delay(seconds)
% function pause the program
% seconds = delay time in seconds
tic;
while toc < seconds
end
return;