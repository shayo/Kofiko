function afFilteredSignal = fnBiLateral1D(afOriginalSignal,fWidth,fBlurSigma,fEdgeSigma)
% Last Update: 3 Apr 2008, (SO)
%
% 1D Bi-lateral filtering
%
% Inputs:
% afOriginalSignal - input vector values
% fWidth - gaussian support (length)
% fBlurSigma - First gaussian sigma 
% fEdgeSigma - Second gaussian sigma
% Outputs:
%
% Notes:  
% Basically, the response of the filter at point x0 with neighnorhood
% A=(x-k,...x-1,x0,x1,...,xk) 
% is the dot product of A and K, where K is weighted kernel that depends
% not only on the absolute distance from x0, but also on the values. 
% 
% For additional information, please read:
%  C. Tomasi and R. Manduchi, "Bilateral Filtering for Gray and Color
%  Images", Proceedings of the 1998 IEEE International Conference on 
%  Computer Vision, Bombay, India.
%%
% Run a med filt 1 first to remove ouliers...
%
iSignalLength = length(afOriginalSignal);
% Pre-compute Gaussian distance weights.
afRange = -fWidth:fWidth;
G = exp(-(afRange.^2)/(2*fBlurSigma^2));

% Apply bilateral filter.
afFilteredSignal = afOriginalSignal;
for iIter = 1:iSignalLength
         % Extract local region.
         iMin = max(iIter-fWidth,1);
         iMax = min(iIter+fWidth,iSignalLength);
         afValues = afOriginalSignal(iMin:iMax);
      
         % Compute Gaussian intensity weights.
         H = exp(-(afValues-afOriginalSignal(iIter)).^2/(2*fEdgeSigma^2));
      
         % Calculate bilateral filter response.
         DotProd = H(:)' .*G((iMin:iMax)-iIter+fWidth+1);
         afFilteredSignal(iIter) = sum(DotProd(:) .* afValues(:) )/sum(DotProd);
end

return;