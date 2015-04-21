
a2fRSmall = randn(20,20,6000);
a2fRand = zeros(100,100,6000,'single');
for k=1:6000
    a2fRand(:,:,k) = imresize(a2fRSmall(:,:,k), [100 100],'nearest');
end
save('C:\Shay\Data\StimulusSet\ClassificationImage\a2fRand_20x20x6000','a2fRand','a2fRSmall');


a2fRand = zeros(100,100,6000,'single');
for k=1:6000
    a2fRand(:,:,k) = imresize(a2fRSmall(:,:,k), [100 100],'bilinear');
end
save('C:\Shay\Data\StimulusSet\ClassificationImage\a2fRand_20x20x6000_Bilinear','a2fRand','a2fRSmall');




a2fRand = zeros(100,100,6000,'single');
Sz = [100 100];
fAlpha = 1.2;
DC = 10;
[X,Y] = meshgrid(1:Sz(2),1:Sz(1));
D = sqrt((X - Sz(2)/2).^2+(Y-Sz(1)/2).^2) + eps;
f1 = 1./D.^(fAlpha);
f1(round(Sz(1)/2),round(Sz(2)/2)) = DC;

for k=1:6000
    f2 = f1 .* exp(2*pi*i *  (rand(Sz)));
    I = abs(ifft2(fftshift(f2)));
    I = I - mean(I(:));
    I = I / std(I(:));
    a2fRand(:,:,k) = I;
end

save('C:\Shay\Data\StimulusSet\ClassificationImage\a2fRand_Pink_100x100x6000_Alpha1p2','a2fRand');
figure(10);
imshow(a2fRand(:,:,5023),[]);



I=fnPinkNoise3([100 100], 1.5);
figure(1);
clf;
imshow(I,[]);
impixelinfo
