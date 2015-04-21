 % Simulate new tetrode pipeline....
 
 iNumChannels = 16;
  a2iTetrodeChannelTable = [1,2,3,4;5,6,7,8];
 iNumTetrodes = size(a2iTetrodeChannelTable,1);
abTetrodeChannels = zeros(1,1+iNumChannels )>0;
abSingleChannels = zeros(1,1+iNumChannels )>0;
abTetrodeChannels(1+a2iTetrodeChannelTable(:)) = true;
abSingleChannels(1+ setdiff(1:iNumChannels, a2iTetrodeChannelTable(:))) = true;
 % Step 1: Regroup timestamps
 
 % 1.1 - Determine which channels need to be groupped.
 aiChRaw = a2fSpikeAndEvents(:,2);
abTetrodeEvent = abTetrodeChannels(aiChRaw+1);
abSingleElectrodeEvent = abSingleChannels(aiChRaw+1);

 aiCh = aiChRaw(abTetrodeEvent);
 afTS = a2fSpikeAndEvents(abTetrodeEvent,4);
 % 1.2 sort time stamps
[afSortedTS, aiInd]=sort(afTS);
aiSortedCh = aiCh(aiInd);

a2iRegroupping = GroupChannelsToTetrode(afSortedTS,aiSortedCh, a2iTetrodeChannelTable);


% 1.3 build table
iNumUniqueTS= sum(diff(afSortedTS)>0);
iNumTS = length(afSortedTS);
% Build the tetrode timestamp/channel table ( This needs to be a mex
% function because it is too slow)
iActiveEntry = 1;
fPrevTS = afSortedTS(1);
a2iInd = zeros(4, iNumTetrodes);
a2fSortedEventsTable = zeros(iNumTetrodes*iNumUniqueTS, 5);  % indices to wave forms/ts. last column denotes which tetrode was triggered
iActiveLine = 1;
for iIter=1:iNumTS
    fCurrentTS = afSortedTS(iIter);
    iCurrentChannel = aiSortedCh(iIter);
        if fCurrentTS == fPrevTS
            a2iInd(iCurrentChannel)=iIter;
        else
            % Time to add events to the table....
            abValidEntries = sum(a2iInd' == 0,2)==0;
            aiValidTetrodes = find(abValidEntries);
            iNumValidEntries=sum(abValidEntries);
            if iNumValidEntries > 0
                a2fSortedEventsTable(iActiveLine:iActiveLine+iNumValidEntries-1,:) = [a2iInd(:,abValidEntries)',aiValidTetrodes(:)];
                iActiveLine=iActiveLine+iNumValidEntries;
                a2iInd = zeros(4, iNumTetrodes);
            end
            fPrevTS = fCurrentTS ;
            a2iInd(iCurrentChannel)=iIter;
        end
end
a2fGroupEvents = a2fSortedEventsTable(1:iActiveLine-1,:);
save('DebugForGrouping','aiSortedCh','afSortedTS','a2iTetrodeChannelTable','a2fGroupEvents');

% if training...
 a2fWaves = a2fWaveForms(abTetrodeEvent,:);

a2fSortedWaveForms =a2fWaves(aiInd,:);

% PCA
a3fPCACoeff = zeros(160, 2, iNumTetrodes);
a2fPCAZeroCorrection= zeros(iNumTetrodes, 2);
a2fPCARange = zeros(iNumTetrodes,4);
for iTetrodeIter=1:iNumTetrodes
    abRelevantEntries = a2fGroupEvents(:,5) == iTetrodeIter;
    X=[a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,1),:), a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,2),:),a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,3),:),a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,4),:)];
    % Run pca...
    a2fPCAMean(iTetrodeIter,:) = mean(X,1);
    Y = bsxfun(@minus,X,a2fPCAMean(iTetrodeIter,:));
    [coeff,ignore] = eig(Y'*Y);
    a3fPCACoeff(:,:,iTetrodeIter) = [coeff(:,end-1), coeff(:,end)];
    a2fPCA = a2fSortedAllWaveFormsZeroMean*[coeff(:,end-1), coeff(:,end)];
    % Quantize PCA    
    a2fPCAZeroCorrection(iTetrodeIter,:) = a2fPCAMean(iTetrodeIter,:) *  a3fPCACoeff(:,:,iTetrodeIter) ;
    a2fPCARange(iTetrodeIter,:)= [min(a2fPCA,[],1), max(a2fPCA,[],1)];
end
% ZeroShift correction in PCA space reduces to:



% Quantize PCA space 
iNumPointsPCASpace = 5000;

% Apply PCA
for iTetrodeIter=1:iNumTetrodes
    abRelevantEntries = a2fGroupEvents(:,5) == iTetrodeIter;
    iNumRelevantEntries = sum(abRelevantEntries);
    X=[a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,1),:), a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,2),:),a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,3),:),a2fSortedWaveForms(a2fGroupEvents(abRelevantEntries,4),:)];
    a2fPCA_Tmp = X*a2fPCACoeff;
    a2fPCA = [a2fPCA_Tmp(:,1) - a2fPCAZeroCorrection(iTetrodeIter,1), a2fPCA_Tmp(:,2) - a2fPCAZeroCorrection(iTetrodeIter,2)];
    
    % Quantize values
    aiX=round((a2fPCA(:,1)-a2fPCARange(iTetrodeIter,1))/(a2fPCARange(iTetrodeIter,3)-a2fPCARange(iTetrodeIter,1))*iNumPointsPCASpace);
    aiY=round((a2fPCA(:,2)-a2fPCARange(iTetrodeIter,2))/(a2fPCARange(iTetrodeIter,4)-a2fPCARange(iTetrodeIter,2))*iNumPointsPCASpace);

     % Apply PCA-region based spike sorting...
     
end
