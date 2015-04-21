function [afFSI, afQuality,afDprime] = fnGetFSI_And_Quality(acUnits)
aiNumSpikes = zeros(1,length(acUnits));
afMUA = zeros(1,length(acUnits));
afMaxStd = zeros(1,length(acUnits));
afAmpRange = zeros(1,length(acUnits));
afFSI = zeros(1,length(acUnits));
afQuality= zeros(1,length(acUnits));
afDprime = zeros(1,length(acUnits));
for k=1:length(acUnits)
    if ~isfield(acUnits{k},'m_afAvgWaveForm')
        continue;
    end;
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    afMUA(k) = sum(acUnits{k}.m_afISIDistribution(1:2))/  sum(acUnits{k}.m_afISIDistribution) * 100;
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);

    fFaceRes = fnMyMean(acUnits{k}.m_afAvgFirintRate_Stimulus(1:16));
    fNonFaceRes = fnMyMean(acUnits{k}.m_afAvgFirintRate_Stimulus(17:96));
    afFSI(k) = (fFaceRes-fNonFaceRes)/(fFaceRes+fNonFaceRes);    
    afQuality(k) = afMaxStd(k)./afAmpRange(k);
    afDprime(k) = fnDPrimeROC(acUnits{k}.m_afAvgStimulusResponseMinusBaseline(1:16),acUnits{k}.m_afAvgStimulusResponseMinusBaseline(17:96));
end