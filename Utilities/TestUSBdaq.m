addpath('Z:\MEX\x64');
h=fnDAQusb('Init',0)
figure(1);
clf;
while (1)
    A=GetSecs();
for k=1:1000
    
    v(k)=fnDAQusb('GetAnalog',0);
end
B=GetSecs();

    plot(v)
    drawnow
end
clear mex		