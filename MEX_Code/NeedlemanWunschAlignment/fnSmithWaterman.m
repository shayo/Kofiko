function aiSentToRecvMapping=fnSmithWaterman(afInterSyncSent, afInterSyncReceived)
% Smith–Waterman algorithm 
% http://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm
% Size(H,1) = length(afInterSyncSent)+1

iNumSyncSent = length(afInterSyncSent);
iNumSyncRecv = length(afInterSyncReceived);

% Initialize
H = NaN*ones(1+iNumSyncSent, 1+iNumSyncRecv);
H(1,:) = 0;
H(:,1) = 0;
Ind = zeros(1+iNumSyncSent, 1+iNumSyncRecv);

% Fill values
while (1)
    [i,j] = find(isnan(H),1,'first');
    if isempty(i)
        break;
    end;
    assert(~isnan(H(i-1,j-1)) &~isnan( H(i-1,j)) & ~isnan(H(i,j-1)));
    Hm = H(i-1,j-1) + fnWeight(afInterSyncSent(i-1), afInterSyncReceived(j-1));
    Hd = H(i-1,j) + fnWeight(afInterSyncSent(i-1), []);
    Hi = H(i,j-1) + fnWeight([], afInterSyncReceived(j-1));
    
    [Hmax, iMaxInd] = max([0,Hm,Hd,Hi]);
    H(i,j) = Hmax;
    
    switch iMaxInd
        case 1
        case 2
            Ind(i,j) = sub2ind(size(H), i-1,j-1);
        case 3
            Ind(i,j) = sub2ind(size(H), i-1,j);            
        case 4
            Ind(i,j) = sub2ind(size(H), i,j-1);            
    end
   
end

% Backtrack....
[fDummy, iIndex] = max(H(:));
%iIndex=find(H(:) == max(H(:)),1,'last');
aiPath = [iIndex];
while (1)
    if H(iIndex) == 0
        break;
    else
        iIndex = Ind(iIndex);
        aiPath = [aiPath,iIndex];
    end
end
[aiSentInd, aiRecvInd] = ind2sub(size(H),aiPath);
B = zeros(size(H),'uint8')>0;
B(aiPath) = true;

H
B
aiSentToRecvMapping = zeros(1, iNumSyncSent);
aiSentToRecvMapping(aiSentInd-1) = aiRecvInd-1;

return;

function fWeight = fnWeight(fSentSyncValue, fRecvSyncValue)
if isempty(fSentSyncValue) 
    % deletion
    fWeight = -1;
    return;
end

if isempty(fRecvSyncValue)
    % insertion
    fWeight = -2;
    return;
end

% Number of TRs match ?
fJitterSec = 1;%3*1e3; % allow 3 ms jitter (?)
if abs(fSentSyncValue-fRecvSyncValue) <= fJitterSec 
    fWeight = 6;
else
    fWeight = -10;
end

return;