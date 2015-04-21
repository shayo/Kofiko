function [f1,f2,afFP,afTP]=fnHistTwoClass(afPos,afNeg)
afPos = afPos(~isnan(afPos));
afNeg= afNeg(~isnan(afNeg));
[W,T]=fnFisherDiscriminant(afPos(:),afNeg(:));

fDeno = sqrt( (std(afPos).^2+std(afNeg).^2)/2);
dprime = abs(mean(afPos) - mean(afNeg)) / (fDeno+eps);

afX = linspace(min([afPos(:);afNeg(:)]),max([afPos(:);afNeg(:)]), 20);
afHistPos = hist(afPos,afX);
afHistNeg = hist(afNeg,afX);

f1=figure;
clf;
hold on;
bar(afX,[afHistPos;afHistNeg]',0.7);
plot(afX,afHistPos,'b','LineWidth',3);
plot(afX,afHistNeg,'r','LineWidth',3);
%plot([T/W T/W],[0 max([afHistPos(:);afHistNeg(:)])],'g','LineWidth',2);
xlabel('Normalized Firing Rate (baseline subtracted)');
ylabel('Number of Images');
legend('Face','Non Face');
f2=figure;
clf;
hold on;

afT = linspace(min([afPos(:);afNeg(:)]),max([afPos(:);afNeg(:)]), 1000);
afTP = zeros(1,1000);
afFP = zeros(1,1000);
for k=1:length(afT)
    afTP(k) = sum(afPos > afT(k)) / length(afPos);
    afFP(k) = sum(afNeg > afT(k)) / length(afNeg);
end
plot(afFP,afTP,'LineWidth',2);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
grid on
box on
hold on;
axis equal
axis([-.05 1.05 -.05 1.05 ])
[fDummy,iIndex]=min( afFP.^2+(1-afTP).^2);

plot(afFP(iIndex),afTP(iIndex),'r*');
text(afFP(iIndex),afTP(iIndex)-0.15,sprintf('d'' = %.2f',dprime));