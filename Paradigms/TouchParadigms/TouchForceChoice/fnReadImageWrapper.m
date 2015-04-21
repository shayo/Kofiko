function I = fnReadImageWrapper(strFilename)
I = imread(strFilename);
if strcmp(class(I),'uint16')
    % Rescale to uint8
    warning off;
    I = uint8(double(I) / 65535 * 255);
    warning on;
end
return;
