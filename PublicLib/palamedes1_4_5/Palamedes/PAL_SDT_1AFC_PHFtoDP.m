%
% PAL_SDT_1AFC_PHFtoDP converts proportion hits and proportion false 
% alarms into d'(d-prime) and criterion C for a 1AFC 
% (one-alternative-forced-choice) task, e.g. a Yes/No or symmetric single-
% alternative task
%
% Syntax: [dP C lnB pC]=PAL_SDT_1AFC_PHFtoDP(pHF);
% 
% returns a scalar or N-length vector of d' ('dP'), criterion C ('C'), 
% criterion lnBeta ('lnB') and proportion correct ('pC'), for an Nx2 input 
% matrix of N proportion hits and proportion false alarms ('pHF') defined 
% in the range 0<p<1 (p=proportion)
%
% Example:
%
% [dP C lnB pC]=PAL_SDT_1AFC_PHFtoDP([.5 .3; .7 .2; .9 .1])
%
% returns:
%
% dP =
%
%    0.5244
%    1.3660
%    2.5631
%
%
% C =
%
%     0.2622
%     0.1586
%          0
% 
% 
% lnB =
% 
%     0.1375
%     0.2167
%          0
% 
% 
% pC =
% 
%     0.6000
%     0.7500
%     0.9000
%
% The example input argument consists of a 3 x 2 matrix, with each
% row (demarcated by a semi-colon) consisting of a proportion of hits and 
% a corresponding proportion of false alarms. The columns in the output 
% are the resulting N=3 vectors of dP, C, lnB and pC
%
% Introduced: Palamedes version 1.0.0 (FK)


function [dP C lnB pC]=PAL_SDT_1AFC_PHFtoDP(pHF)

zH=PAL_PtoZ(pHF(:,1));
zF=PAL_PtoZ(pHF(:,2));

dP=zH-zF;
C=-0.5.*(zH+zF);
lnB=-0.5.*(zH.^2-zF.^2);
pC=(pHF(:,1)+(1.0-pHF(:,2)))./2;