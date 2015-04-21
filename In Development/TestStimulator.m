fnDAQ('Init',0);
while (1)
fnDAQ('SetBit',16,0);
tic
while toc < 2
end
fnDAQ('SetBit',16,1);

tic
while toc < 2
end
end
  
t