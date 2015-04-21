function Out=fnGenCombAux2(acM,aiCurrComb,iIndex,Out,iGlobalCounter)
% Generates all vector of length N, with domain 1..M (N^M) using
% backtracking
% Use:
% Out=fnGenCombAux2({[-1,0,1],[1 2 3],[10 20 30 40]},zeros(1,3),1,[])

%iNumComb = N^M;
%a2fComb = zeros(iNumComb, N);
%aiCurrComb = zeros(1,N);
if iIndex > length(acM)
    Out(iGlobalCounter,:)=aiCurrComb;
    iGlobalCounter = iGlobalCounter + 1;
    return;
end;

for k=1:length(acM{iIndex})
    aiCurrComb(iIndex) =acM{iIndex}(k);
    Out=fnGenCombAux2(acM, aiCurrComb, iIndex+1,Out,iGlobalCounter);
end;
return;