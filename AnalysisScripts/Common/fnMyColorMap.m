function I=fnMyColorMap(X, afRange)
if ~exist('afRange','var')
    minX = min(X(:));
    maxX = max(X(:));
else
    minX = afRange(1);
    maxX = afRange(2);
end
Xn = (X-minX) / (maxX-minX);
Xn(X < minX) = 0;
Xn(X > maxX) = 1;

I = zeros(size(X,1),size(X,2),3);

a2fJet = jet(255);

R=interp1( linspace(0,1,255), a2fJet(:,1), Xn(:));
G=interp1( linspace(0,1,255), a2fJet(:,2), Xn(:));
B=interp1( linspace(0,1,255), a2fJet(:,3), Xn(:));
R(isnan(Xn)) = 0;
G(isnan(Xn)) = 0;
B(isnan(Xn)) = 0;
I(:,:,1) = reshape(R, size(X));
I(:,:,2) = reshape(G, size(X));
I(:,:,3) = reshape(B, size(X));
return;

% 
% figure(11);
% clf;
% imagesc(I);
% 
% figure(12);
% clf;
% imagesc(X)