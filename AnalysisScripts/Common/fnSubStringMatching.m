function aiKofikoToPlexonIndexMatching = fnSubStringMatching(aiKofikoValues, aiPlexonValues)
% Try to match the longest sub strings between Kofiko and Plexon vectors
% Returns the indices (!) of matched kofiko values to plexon values 
aiIndicesKofiko = 1:length(aiKofikoValues);
aiIndicesPlexon = 1:length(aiPlexonValues);

aiKofikoValuesOrig = aiKofikoValues;
aiPlexonValuesOrig = aiPlexonValues;
aiKofikoToPlexonIndexMatching = zeros(1,length(aiIndicesKofiko));
iMinimumToMatch  = 2;

while 1
    X = fnLongestCommonString(aiKofikoValues, aiPlexonValues);
    iLengthLongtest = X(1);
    if iLengthLongtest < iMinimumToMatch 
        break;
    else
        KofikoStartIndex = X(2);
        PlexonStartIndex = X(3);
        
        aiIntervalKofiko = aiIndicesKofiko(KofikoStartIndex):aiIndicesKofiko(KofikoStartIndex)+iLengthLongtest-1;
        aiIntervalPlexon = aiIndicesPlexon(PlexonStartIndex):aiIndicesPlexon(PlexonStartIndex)+iLengthLongtest-1;
        aiKofikoToPlexonIndexMatching(aiIntervalKofiko) = aiIntervalPlexon;
        
        aiIndicesKofiko = setdiff(aiIndicesKofiko,     aiIntervalKofiko);
        aiIndicesPlexon = setdiff(aiIndicesPlexon,     aiIntervalPlexon);
        aiKofikoValues = aiKofikoValuesOrig(aiIndicesKofiko);
        aiPlexonValues = aiPlexonValuesOrig(aiIndicesPlexon);
    end
end
   
