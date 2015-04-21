function [aiMapAToB, aiMapBToA,AlignmentA,AlignmentB]=fnNeedlemanWunsch(afA, afB)
iA = length(afA);
iB = length(afB);
F = nans(iA+1,iB+1);

fDeleteWeight = -1;
F(:,1) = fDeleteWeight * [0:iA];
F(1,:) = fDeleteWeight * [0:iB];

for i=2:iA+1
    for j=2:iB+1
        fMatch = F(i-1,j-1) + fnWeight(afA(i-1),afB(j-1));
        fDelete = F(i-1,j) + fDeleteWeight;
        fInsert = F(i,j-1) + fDeleteWeight;
        F(i,j) = max([fMatch, fInsert, fDelete]);
    end
end

AlignmentA  = nans(1,max(iA,iB));
AlignmentB  = nans(1,max(iA,iB));
aiMapAToB = nans(1, max(iA,iB));
aiMapBToA = nans(1, max(iA,iB));
i  = iA+1;
j  = iB+1;
c = max(iA,iB);
while (i > 1 || j > 1)
  if (i > 1 && j > 1 && F(i,j) == F(i-1,j-1) + fnWeight(afA(i-1), afB(j-1)))
    AlignmentA(c)  = afA(i-1);
    AlignmentB(c)  = afB(j-1);
    aiMapAToB(i-1) = j-1;
    aiMapBToA(j-1) = i-1;
    i = i-1;
    j = j-1;
  elseif (i > 1 && F(i,j) == F(i-1,j) + fDeleteWeight)
    AlignmentA(c)  = afA(i-1);
    AlignmentB(c)  = NaN;
    i=i-1;
  else 
    AlignmentA(c)  = NaN;
    AlignmentB(c)  = afB(j-1);
    j=j-1;
  end 
  c = c -1;
end
aiMapAToB=aiMapAToB(1:iA);
aiMapBToA=aiMapBToA(1:iB);

figure;
clf;
hold on;
plot(AlignmentA,'b.')
plot(AlignmentB,'ro')

return


function fWeight = fnWeight(fA,fB)
fMatchWeight = 2;
fMismatchWeight = -3;

Jitter = 0.001;
if abs(fA-fB) < Jitter %;fA == fB
    fWeight = fMatchWeight;
else
    fWeight = fMismatchWeight;
end
