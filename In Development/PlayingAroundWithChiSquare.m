iSessionIter = 2;
iCondition = 2;
Table = [a3fNumTrialsNoStim(iCondition,:,iSessionIter);a3fNumTrialsStim(iCondition,:,iSessionIter)];
Ri=sum(Table,1)
Ci=sum(Table,2)
sum(Table(:))


ChiSquareValue = sum((Table(2,:)-Table(1,:)).^2 ./ Table(1,:))
PValue = chi2pdf(ChiSquareValue, 4) < 0.01/8



Table = [
    56   101     2     1
    39    80     6     1]

% Convert Table to frequencies
a2fTableFreq = sum(Table,2) * sum(Table,1) / sum(Table(:))
ChiSquareValue = sum((a2fTableFreq(2,:) - a2fTableFreq(1,:) ) .^2 ./ a2fTableFreq(1,:));
df = 3;
P = 0.01/8;

%df = (#r-1)*(#c-1)
%df = (2-1)*(4-1);
