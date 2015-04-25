function output = runBinaryConv(num)

x = dec2bin(num);
x1 = dec2bin(bitand(str2num(x),255));
%x2 = dec2bin(bitand((bitshift(-dec2bin(num),-8)),127));
x2 = dec2bin(bitand((bitsra((dec2bin(num)),8)),127));
disp(x1)
disp(x2)
output = strcat(num2str(x1),num2str(x2));
end