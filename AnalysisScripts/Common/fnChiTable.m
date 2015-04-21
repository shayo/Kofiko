function [fPValue, fChi2Stat] = fnChiTable(a2iObservedTable, df)
a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
fChi2Stat = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
fPValue = 1 - chi2cdf(fChi2Stat, df);
return
