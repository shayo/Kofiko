fnDAQWrapper('Init',0);
fMotionPort = 7;
k = 1;
B = 100;
N=10000;
afAnalogSignal = zeros(1,N);
afAngles = zeros(1,N);
figure(1);
clf;
fBaseline = 2715;
fScale =  267.8679;


while (1)
    afAnalogSignal(k) = fnDAQWrapper('GetAnalog',fMotionPort);
    fAngle = -asin((afAnalogSignal(k) - fBaseline) / fScale)/pi*180;
    afAngles(k) = fAngle;
     plot(afAngles(1:k));
    if k > B
        fprintf('%.3f %d %.3f\n', mean(afAngles(k-B:k)),afAnalogSignal(k),fAngle);
    end
    
   k=k+1;
    if k > N
        k = 1;
    end
    
    drawnow
end



[2520,2553,2591,2632, 2677,  2724]-2724
[2818,2860,2897,2932,2960,2991] - 2818

afScales = linspace(100,500,10000);
afErrors = zeros(1,10000);
for k=1:length(afScales)
    fScale = afScales(k);
    R = asin(Y0 / fScale)/pi*180;
    E = sqrt(sum((R-X).^2));
    afErrors(k)=E;
end;
figure(2);
plot(afScales,afErrors)

[fMinError,iIndex] = min(afErrors);
fOptScale = afScales(iIndex)


figure(2);
clf;
plot(X,Y);

-30 = 2632
-20 = 2677
 -10 = 2724
 0 = 2772
 10 = 2818
 20 = 2860
 30 = 2897
 