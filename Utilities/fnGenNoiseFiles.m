
a3fRand = rand(40,40,15000,'single');
save('Uniform_40x40x15k','a3fRand');

N=15000;
a3fRand = zeros(41,41,N,'single');
for k=1:N
    X=fnPinkNoise([20,20],  2);
    X=(X-min(X(:)))/(max(X(:))-min(X(:)));
     a3fRand(:,:,k)=X;
end
save('Pink2_41x41x15k','a3fRand');
