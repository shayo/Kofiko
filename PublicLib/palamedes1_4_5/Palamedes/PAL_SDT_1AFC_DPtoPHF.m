%
% PAL_SDT_1AFC_DPtoPHF converts d'(d-prime) for a criterion C into 
% proportion hits and proportion false alarms for a 1AFC 
% (one-alternative-forced-choice) task, e.g. a Yes/No or symmetric single-
% alternative task
%
% Syntax: [pHF]=PAL_SDT_1AFC_DPtoPHF(dP,C);
% 
% returns a Nx2 matrix of N proportion hits and proportion false alarms 
% ('pHF') for a scalar or N-length vector of d' ('dP') and criterion C 
% ('C'), defined in the ranges 0<d'<inf and -inf<C<inf
%
% Example:
%
% [pHF]=PAL_SDT_1AFC_DPtoPHF([.0 1 10],[-2.5 0 4.0])
%
% pHF =
%
%    0.9938    0.9938
%    0.6915    0.3085
%    0.8413         0
%
% The example input arguments are two N=3 vectors of d' and C.  The first 
% column of the 3 x 2 matrix output gives the resulting proportion of hits 
% and the second column the corresponding proportion of false alarms
%
% Introduced: Palamedes version 1.0.0 (FK)

function pHF = PAL_SDT_1AFC_DPtoPHF(dP,C)

zH=dP./2 - C;
zF=-dP./2 - C;

pHF(:,1)=PAL_ZtoP(zH);
pHF(:,2)=PAL_ZtoP(zF);