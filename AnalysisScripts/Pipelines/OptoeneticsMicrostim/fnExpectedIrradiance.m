WaveLength_nm = 473;
Fiber_NA = 0.22;
PowerAtTip_mW = 1.9;
FiberCoreDiameter_mm = 0.1;

Tissue_NA = 1.36;
ScatterCoeff = 11.3;
Radius = FiberCoreDiameter_mm

afDistFromTipMM = linspace(0,3,1000);

HalfAngleDiv_Rad = asin(Fiber_NA / Tissue_NA)
HalfAngleDiv_Deg =HalfAngleDiv_Rad/pi*180

Rho = Radius * sqrt( (Tissue_NA/Fiber_NA)^2-1);

Intensity = PowerAtTip_mW * Rho^2 ./ (  (ScatterCoeff*afDistFromTipMM+1) .* (Rho + afDistFromTipMM).^2);
Irradiance_mWmm2 = Intensity ./ (pi*Radius^2);

figure(2);
subplot(1,2,1);
plot(afDistFromTipMM,Irradiance_mWmm2)
xlabel('Distance from tip(mm)');
ylabel('Irradiance (mW/mm^2)');
subplot(1,2,2);
semilogy(afDistFromTipMM,Irradiance_mWmm2)
xlabel('Distance from tip(mm)');
ylabel('Irradiance (mW/mm^2)');

fDistFromTipMM = 0.0;f0= PowerAtTip_mW ./ (pi*Radius^2) * Rho^2 ./ (  (ScatterCoeff*fDistFromTipMM+1) .* (Rho + fDistFromTipMM).^2) ;
fDistFromTipMM = 0.5;f1= PowerAtTip_mW ./ (pi*Radius^2) * Rho^2 ./ (  (ScatterCoeff*fDistFromTipMM+1) .* (Rho + fDistFromTipMM).^2) ;
fDistFromTipMM = 1;f2= PowerAtTip_mW ./ (pi*Radius^2) * Rho^2 ./ (  (ScatterCoeff*fDistFromTipMM+1) .* (Rho + fDistFromTipMM).^2) ;

fprintf('Irradiance at 0.5mm is %.2f and at 1mm is %.2f\n',f1,f2);
    

