acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};

for k=1:55
    a2iPoly(:,k) = a2iPerm(:,a2iPairs(k,1)) .* a2iPerm(:,a2iPairs(k,2)) ;
end

a2iPolyExt = a2iPoly;
for k=1:11
    a2iPolyExt(:,k+55) = a2iPerm(:,k).^2;
end


a2iSign11 = a2iPermExt(:,[ 11    30     2    13    29    19     7    52    27    25     6]);
 
[afOptS, afRes, fRsqrS,fRsqrAdjuS,afPredSign11]  = fnRegress(a2iSign11, afNormRes);

[afOptW, afRes, fRsqr,fRsqrAdju,afPredLum]  = fnRegress(a2iPerm, afNormRes);
[afOptS, afRes, fRsqrS,fRsqrAdjuS,afPredSign]  = fnRegress(a2iPermExt, afNormRes);
[afOptWP, afRes, fRsqrP,fRsqrAdjuP,afPredPoly2]  = fnRegress([a2iPerm,a2iPoly], afNormRes);
[afOptWP, afRes, fRsqrP,fRsqrAdjuP,afPredPoly1]  = fnRegress([a2iPoly], afNormRes);





afUnitResponse = acUnits{42}.m_afAvgStimulusResponseMinusBaseline;
fMin = min(afUnitResponse(1:97+432-1));
fMax = max(afUnitResponse(1:97+432-1));
afNormResUnit =(afUnitResponse(97:97+432-1)-fMin)/(fMax-fMin) ;



            f = @(p,x) p(1) + p(2) ./ (1 + exp(-(x-p(3))/p(4)));

            afAvgFiringRate = a2fDiff(2,:)
            p1 = min(afAvgFiringRate);
            p2 = max(afAvgFiringRate)-p1;
            p3 = 0;
            p4 = 3;
            pi = [p1,p2,p3,p4];
            opt=statset('MaxIter',100,'robust','on');
            ppos = nlinfit(afX,afAvgFiringRate,f,pi,opt);
            fpos = f(ppos,afX);
            pi(4) = -3;
            pneg = nlinfit(afX,afAvgFiringRate,f,pi,opt);
            fneg = f(pneg,afX);
            abNonNaNsPos = ~isnan(fpos) & ~isnan(afAvgFiringRate);
            abNonNaNsNeg = ~isnan(fneg) & ~isnan(afAvgFiringRate);
            corpos = corr(fpos(abNonNaNsPos)', afAvgFiringRate(abNonNaNsPos)');
            corneg = corr(fneg(abNonNaNsNeg)', afAvgFiringRate(abNonNaNsNeg)');


% [a2fFirstOrder,a3fSecondOrder,a2fDiff] = fnReconstructContrastCurve(a2iPerm, afPredLum);
% figure(13);clf;
% for k=1:55
%     subplot(7,8,k);
%     plot(-10:10,a2fDiff(k,:));
% end

[a2fFirstOrder,a3fSecondOrder] = fnReconstructContrastCurve(a2iPerm, afNormRes);


[a2fFirstOrderSign11,a3fSecondOrderSign11] = fnReconstructContrastCurve(a2iPerm, afPredSign11);

[a2fFirstOrderLum,a3fSecondOrderLum] = fnReconstructContrastCurve(a2iPerm, afPredLum);
[a2fFirstOrderSign,a3fSecondOrderSign] = fnReconstructContrastCurve(a2iPerm, afPredSign);
[a2fFirstOrderPoly2,a3fSecondOrderPoly2] = fnReconstructContrastCurve(a2iPerm, afPredPoly2);
[a2fFirstOrderPoly1,a3fSecondOrderPoly1] = fnReconstructContrastCurve(a2iPerm, afPredPoly1);

[a2fFirstOrderUnit,a3fSecondOrderUnit] = fnReconstructContrastCurve(a2iPerm, afNormResUnit);
[afOptW, afRes, fRsqrLum,fRsqrAdju,afPredLumUnit]  = fnRegress(a2iPerm, afNormResUnit);
[afOptS, afRes, fRsqrS,fRsqrAdjuS,afPredSign11Unit]  = fnRegress(a2iSign11, afNormResUnit);

[a2fFirstOrderSign11Unit,a3fSecondOrderSign11Unit] = fnReconstructContrastCurve(a2iPerm, afPredSign11Unit);
[a2fFirstOrderLumUnit,a3fSecondOrderLumUnit] = fnReconstructContrastCurve(a2iPerm, afPredLumUnit);

[afOptW, afRes, fRsqrSign,fRsqrAdju,afPredSignUnit]  = fnRegress(a2iPermExt, afNormResUnit);
[afOptW, afRes, fRsqrPoly2,fRsqrAdju,afPredPoly2Unit]  = fnRegress([a2iPerm,a2iPolyExt], afNormResUnit);


[a2fFirstOrderSignUnit,a3fSecondOrderSignUnit] = fnReconstructContrastCurve(a2iPerm, afPredSignUnit);

[a2fFirstOrderPoly2Unit,a3fSecondOrderPoly2Unit] = fnReconstructContrastCurve(a2iPerm, afPredPoly2Unit);

figure(20);clf;
for k=1:11
   subplot(3,4,k);hold on;
   plot(1:11,a2fFirstOrderUnit(k,:));
   plot(1:11,a2fFirstOrderLumUnit(k,:)','r');
   plot(1:11,a2fFirstOrderSignUnit(k,:)','g');
   axis([1 11 0.25 0.5]);
   set(gca,'xtick',1:11,'ytick',0.2:0.1:0.5);
   title(sprintf('part %d (%s)',k,acPartNames{k}));
end


figure(11);clf;fnDisplayContrastMatrix(a3fSecondOrder,[0.15 0.3]);colorbar
figure(12);clf;fnDisplayContrastMatrix(a3fSecondOrderLum,[0.15 0.3]);colorbar
figure(13);clf;fnDisplayContrastMatrix(a3fSecondOrderSign11,[0.15 0.3]);colorbar

figure(14);clf;fnDisplayContrastMatrix(a3fSecondOrderUnit,[0.2 0.5]);colorbar
figure(15);clf;fnDisplayContrastMatrix(a3fSecondOrderLumUnit,[0.2 0.5]);colorbar
figure(16);clf;fnDisplayContrastMatrix(a3fSecondOrderSign11Unit,[0.2 0.5]);colorbar

for k=1:55
    a2fM = a3fSecondOrderUnit(:,:,k);
    a2fL = a3fSecondOrderLumUnit(:,:,k);
    a2fP = a3fSecondOrderSign11Unit(:,:,k);
    abNotNaN = ~isnan(a2fM(:));
    afValues = a2fM(abNotNaN);
    afCorrToLum(k) = corr(afValues, a2fL(abNotNaN));
    afCorrToPol(k) = corr(afValues, a2fP(abNotNaN));
end



figure(11);clf;fnDisplayContrastMatrix(a3fSecondOrderUnit,[0.1 0.6]);colorbar
figure(11);clf;fnDisplayContrastMatrix(a3fSecondOrderLumUnit,[0.1 0.6]);colorbar
figure(11);clf;fnDisplayContrastMatrix(a3fSecondOrderPoly2Unit,[0.1 0.6]);colorbar

figure(12);clf;fnDisplayContrastMatrix(a3fSecondOrderSignUnit,[0.1 0.6]);colorbar

figure(13);clf;fnDisplayContrastMatrix(a3fSecondOrder-a3fSecondOrderPoly2,[-0.05 0.05]); colormap jet;colorbar
figure(13);clf;fnDisplayContrastMatrix(a3fSecondOrderPoly2); colormap jet;colorbar


figure(20);clf;
for k=1:11
   subplot(3,4,k);
   plot(1:11,a2fFirstOrder(k,:));
   hold on;
 %  plot(1:11,a2fFirstOrderLum(k,:),'r');
    plot(1:11,a2fFirstOrderSign(k,:),'g');
%    plot(1:11,a2fFirstOrderPoly2(k,:),'c');
%    
   axis([1 11 0.2 0.3]);
   set(gca,'xtick',1:11,'ytick',0.2:0.05:0.3);
   title(sprintf('Part (%s)',acPartNames{k}));
end

%%  SVD Stuff
a3fContrastAug = fnAugmentWithNearestNeighbor(a3fContrast);

for k=1:55
    [U,S,V]=svd(1e3*a3fContrastAug(:,:,k));
    a2fPower(k,:) = diag(S);
    S(2:end,2:end)=0;
    a3fReconstruction(:,:,k) = U*S*V';
end

figure;
plot(a2fPower')
xlabel('Singular Value index');
ylabel('Singluar Value');



acUnits{50}


% Reconsturction of the joint tuning curves using sign model


afAvgLum = mean(a2iPerm,1);

figure(20);clf;
for k=1:11
    subplot(3,4,k);
   %errorbar(1:11,a2fAvgLuminanceResponse(k,:),a2fStdLuminanceResponse(k,:));hold on;
   plot(1:11,a2fAvgLuminanceResponse(k,:),'linewidth',2);
   
    hold on;
    plot(1:11,a2fAvgLuminanceResponsePredPoly1(k,:),'r','linewidth',2);
    plot(1:11,a2fAvgLuminanceResponsePredPoly2(k,:),'g','linewidth',2);
    
    axis([1 11 0.2 0.3]);
    set(gca,'xtick',1:11,'ytick',0.2:0.05:0.3);
    title(sprintf('part %d (%s)',k,acPartNames{k}));
end


