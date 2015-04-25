function [R] = weightedRandTest()


tic

a = 1:3;             %# possible numbers
w = [1 1 1]./3;   %# corresponding weights
N = 100000;              %# how many numbers to generate

R = a( sum( bsxfun(@ge, rand(N,1), cumsum(w./sum(w))), 2) + 1 )

toc