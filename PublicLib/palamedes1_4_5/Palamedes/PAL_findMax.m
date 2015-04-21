%
%PAL_findMax   find value and position of maximum in 2, 3 or 4-D array
%
%   syntax: [maxim I] = PAL_findMax(array)
%
%   [maxim I] = PAL_findMax(array) returns the value and position of 
%       maximum in a 2, 3, or 4D array.
%
%   For vectors, PAL_findMax differs from Matlab's resident 'max' in that 
%   output argument 'I' has two elements: [row, column].
%
%   Example:
%
%       x = zeros(5,5,5);
%       x(1,2,3) = 12;
%       [maxim I] = PAL_findMax(x)
%
%       returns:
%
%       maxim =  
%
%           12
%       I =
%
%           1     2     3
%
% Introduced: Palamedes version 1.1.1 (NP)
% Modified: Palamedes version 1.2.0 (NP). Added 4D array. 
% Modified: Palamedes version 1.2.0 (NP). Modified such that routine works 
%   with array containing singleton dimensions. 
% Modified: Palamedes version 1.2.0 (NP). Fixed issue with function name 
%   (findMax -> PAL_findMax). 
% Modified: Palamedes version 1.2.0 (NP). Reduced memory load by
%   avoiding creation of maxVal array that existed in earlier version.


function [maxim Indices] = PAL_findMax(array)

singletonDim = uint16(size(array) == 1);
array = squeeze(array);    

if ndims(array) == 2           
    if isvector(array)        
        [maxim IndicesSqueezed] = max(array);
    else
        [array I] = max(array);
        [maxim I2] = max(array);
        IndicesSqueezed = [I(I2) I2];
    end
end
if ndims(array) == 3
    [array I] = max(array);
    [array I2] = max(array);
    [maxim I3] = max(array);
    IndicesSqueezed = [I(1,I2(I3),I3) I2(I3) I3];
end
if ndims(array) == 4        
    [array I] = max(array);        
    [array I2] = max(array);    
    [array I3] = max(array);   
    [maxim I4] = max(array);        
    IndicesSqueezed = [I(1,I2(1,1,I3(I4),I4),I3(I4),I4) I2(1,1,I3(I4),I4) I3(I4) I4];
end

singletonDim(singletonDim == 0) = IndicesSqueezed;
Indices = singletonDim;

