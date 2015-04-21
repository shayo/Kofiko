function I = fnMutualInformation(P)
% Mutual information ?
% r = rand(1,10);
% P = r'*r;%rand(10,10);

% Make sure P is a probability mass function
P = P / sum(P(:));
% 
% Px = sum(P,2);
% Px = Px / sum(Px);
% Py = sum(P,1);
% Py = Py / sum(Py);
% I = 0;
% for x=1:10
%     for y=1:10
%        I = I +  P(x,y) * log(P(x,y) / (Px(x)*Py(y)));
%     end
% end

[a2iX, a2iY] = meshgrid(1:size(P,2),1:size(P,1));
I = sum(sum(P .* log( P ./ (Px(a2iX) .*  Py(a2iY)))));

return;