function [r2] = RsqrStat(y,yhat)
%yhat=afPredResponse1
%y=afNormRes

r = y-yhat;                     % Residuals.
normr = norm(r);

SSE = normr.^2;              % Error sum of squares.
RSS = norm(yhat-mean(y))^2;  % Regression sum of squares.
TSS = norm(y-mean(y))^2;     % Total sum of squares.
r2 = 1 - SSE/TSS;            % R-square statistic.
