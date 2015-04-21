% Generate a random sequence
X = rand(1,10000)*1e2 ;
afSyncSentTimes = cumsum(X);

afSyncRecvTimes = afSyncSentTimes ;

afDiffSent = diff(afSyncSentTimes);
afDiffRecv = diff(afSyncRecvTimes);
afDiffRecv(2:5) = [];

aiSentToRecvMapping=fnSmithWaterman(afDiffSent, afDiffRecv)