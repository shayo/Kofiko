N=432; % points
X=1:N;
P=ones(N,1);
P = [randperm(11)',randperm(11)'];
P(X>N/2) = 1;

P(X<=N/2) = 0;
P(X>N/2) = 1;

Pa = [P, ones(size(P))];

Y = Pa * [0.05,10]';

Yn=Y+randn(size(Y));

B = inv(Pa'*Pa)*Pa'*Yn;

Yr = Pa * B;
Re = Yr-Yn;
df = (N-rank(Pa));
SigmaHatSqr = Re'*Re / df;

% testing c'*B=d
d=0;
c=[1 1];
Tstat = (c*B-d) / sqrt(SigmaHatSqr*c*inv(Pa'*Pa)*c');
% Tstat has t distribution with (N-rank(Pa)) DF
p = 2 * tcdf(-abs(Tstat), df)

figure(11);
clf;
hold on;
plot(X,Yn,'.');
plot(X,Y,'r.');
plot(X,P,'g.');
plot(X,Yr,'c.');
legend('Yn','Y','P');


%plot(X, Pa(1)*B(1)+