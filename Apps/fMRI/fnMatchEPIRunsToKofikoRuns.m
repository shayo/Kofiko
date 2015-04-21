function aiEPIIndexToKofikoIndex = fnMatchEPIRunsToKofikoRuns(acHeaders, astrctKofikoRuns)
iNumEPIs = length(acHeaders);
iNumKofikoRuns = length(astrctKofikoRuns);
aiEPIIndexToKofikoIndex = zeros(1,iNumEPIs);
if iNumKofikoRuns == 0 || iNumEPIs == 0
    return;
end

aiNumTRinEPI = zeros(1,iNumEPIs);
for k=1:length(acHeaders)
    aiNumTRinEPI(k) = acHeaders{k}.nframes;
end
aiNumTRinKofiko = zeros(1,iNumKofikoRuns);
for k=1:iNumKofikoRuns
    aiNumTRinKofiko(k) = astrctKofikoRuns(k).m_iNumberOfCountedTRs;
end

% if iNumEPIs ~= iNumKofikoRuns
%    fprintf('Warning. Number of EPIs and number of recorded Kofiko runs mismatch!\n');
%    fprintf('Trying to match anyway...\n');
% end

% use Smith–Waterman algorithm 
% http://en.wikipedia.org/wiki/Smith%E2%80%93Waterman_algorithm

% We assume that both sequences are in proper time-stamp order

% Initialize
H = NaN*ones(1+iNumEPIs, 1+iNumKofikoRuns);
H(1,:) = 0;
H(:,1) = 0;
Ind = zeros(1+iNumEPIs, 1+iNumKofikoRuns);

% Fill values
while (1)
    [i,j] = find(isnan(H),1,'first');
    if isempty(i)
        break;
    end;
    
    Hm = H(i-1,j-1) + fnWeight(aiNumTRinEPI(i-1), aiNumTRinKofiko(j-1));
    Hd = H(i-1,j) + fnWeight(aiNumTRinEPI(i-1), []);
    Hi = H(i,j-1) + fnWeight([], aiNumTRinKofiko(j-1));
    
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
[aiEPI_Ind, aiKofiko_Ind] = ind2sub(size(H),aiPath);

aiEPIIndexToKofikoIndex = zeros(1, iNumEPIs);
aiEPIIndexToKofikoIndex(aiEPI_Ind-1) = aiKofiko_Ind-1;

return;

function fWeight = fnWeight(iNumInEPI, iNumInKofiko)
if isempty(iNumInEPI) 
    % deletion
    fWeight = -2;
    return;
end

if isempty(iNumInKofiko)
    % insertion
    fWeight = -1;
    return;
end

% Number of TRs match ?
if abs(iNumInEPI-iNumInKofiko) <= 1 % allow one TR to disappear....
    fWeight = 2;
else
    fWeight = -2;
end

return;