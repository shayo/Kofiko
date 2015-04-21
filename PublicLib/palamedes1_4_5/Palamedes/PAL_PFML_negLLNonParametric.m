%
%PAL_PFML_negLLNonParametric     (negative) Log Likelihood associated with 
%   saturated model.
%
%Syntax: negLL = PAL_negLLNonParametric(NumPos, OutOfNum)
%
%Requires trials to have been grouped (e.g., using PAL_PFML_GroupTrialsByX)
%
%Internal Function
%
% Introduced: Palamedes version 1.0.0 (NP)
% Modified: Palamedes version 1.1.0 (NP). Returns the number of free
%   parameters.

function [negLL numParams] = PAL_PFML_negLLNonParametric(NumPos, OutOfNum)

pcorrect = NumPos./OutOfNum;

negLL = -sum(sum(NumPos(NumPos~=0).*log(pcorrect(NumPos~=0))))-sum(sum((OutOfNum(NumPos~=OutOfNum)-NumPos(NumPos~=OutOfNum)).*log(1 - pcorrect(NumPos~=OutOfNum))));
numParams = sum(sum(OutOfNum~=0));