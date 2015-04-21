addpath(genpath('W:\'));
afEyeXpix=rand(1,1000);
Y=fnBiLateral1D(afEyeXpix,70,60,30);
Ymex=fndllBilateral1D(afEyeXpix,70,60,30);
