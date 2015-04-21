function strctUnit = fnAnalyzeViolaJones(strctUnit, strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

afAvgResponse = strctUnit.m_afAvgStimulusResponseMinusBaseline;
%afAvgResponse = strctUnit.m_afAvgFirintRate_Stimulus

afFacesRes = afAvgResponse(1:150);
afSortedFaceRes = sort(afFacesRes);

fPercentile = 0.9;

fPercentileRes = afSortedFaceRes(round(fPercentile*length(afFacesRes)));

afNonFaceRes = afAvgResponse(151:380);

strctStatVJ.m_aiFalseAlarms = 150+find(afNonFaceRes > fPercentileRes);
strctStatVJ.m_iNumFalseAlarms = length(strctStatVJ.m_aiFalseAlarms);
fprintf('%d FA survived the %.2f percentile\n',strctStatVJ.m_iNumFalseAlarms,fPercentile);
strctTmp = load('a3iViolaJonesImages');

a3fVJ = double(strctTmp.a3iImages);

strctStatVJ.m_a2fAvgFA = mean(a3fVJ(:,:, strctStatVJ.m_aiFalseAlarms),3);

%%
afResPos =afFacesRes;
afResPos = afResPos(~isnan(afResPos));

afResNeg =afNonFaceRes;
afResNeg = afResNeg(~isnan(afResNeg));

fDeno = sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);
dPrime = abs(mean(afResPos) - mean(afResNeg)) / (fDeno+eps);
fPerecentCorrect = normcdf(dPrime / sqrt(2)) * 100;

strctStatVJ.m_fdPrime =  dPrime;
strctStatVJ.m_fPerecentCorrect =  fPerecentCorrect;
%%
strctUnit.m_strctStatVJ = strctStatVJ;

return;
