function Values = fnTimeZoneChangeTS_Resampling(strctTS, strFrom, strTo, afNewTime_Target, strctSync)
% Takes a time stamped variable from a machine (strctTS, strFrom)
% and converts the timestamps to another machine (strTo), Then, resamples
% the sampled values at (afTo_Time).
%

afTS_Target = fnTimeZoneChange(strctTS.TimeStamp,strctSync, strFrom, strTo);

abBeforeInvalid = afNewTime_Target < afTS_Target(1);

if length(strctTS.TimeStamp) == 1
    strctTS.Buffer = strctTS.Buffer';
end
iDim = size(strctTS.Buffer,2);

Values = zeros( length(afNewTime_Target), iDim);
for iDimIter=1:iDim
    Values(:,iDimIter) = fnMyInterp1(afTS_Target, squeeze(strctTS.Buffer(:,iDimIter)), afNewTime_Target);
    Values(abBeforeInvalid,iDimIter) = NaN;
end;




