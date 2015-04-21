function a3fContrast = fnAugmentWithNearestNeighbor(a3fContrast)
[XI,YI] = meshgrid(1:size(a3fContrast,2),1:size(a3fContrast,1));
for k=1:size(a3fContrast,3)
    A=a3fContrast(:,:,k);
    B = griddata(XI(~isnan(A)),YI(~isnan(A)),A(~isnan(A)),XI(isnan(A)),YI(isnan(A)),'nearest');
    A(isnan(A)) = B;
    a3fContrast(:,:,k) =A;
end
return;