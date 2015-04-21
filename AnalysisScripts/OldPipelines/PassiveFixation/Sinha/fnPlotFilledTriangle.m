function h=fnPlotFilledTriangle(bUp,Xc,Yc,Sw,Sh,C)
X = [Xc, Xc + Sw, Xc - Sw];
if bUp
    Y  = [Yc, Yc + Sh, Yc+Sh];
else
    Y  = [Yc, Yc - Sh, Yc-Sh];
end

h=fill(X,Y,C);
