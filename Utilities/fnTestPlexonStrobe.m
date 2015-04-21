fnDAQ('Init',0)

fnDAQ('SetBit',17,1);
WaitSecs(1);

afStart=zeros(2^15,1);
afEnd=zeros(2^15,1);
for k=0:(2^15-1)
    afStart(1+k) = GetSecs();
    fnDAQ('StrobeWord',k);
    afEnd(1+k) = GetSecs();
    WaitSecs(5 *1e-3);
end

fnDAQ('SetBit',17,0);
