function fnViolaJonesPopulationAnalysis(acUnits,strctConfig)

%%
warning off
for j=0:100:600
for k=1:15
    try
        close(k+j)
    catch
    end
end
end
warning on
%% Face Selectivity Index
bUseStandardParamOnly = true;
bAnalyzeOnlySubSet = true;

fQuality =  0.5; %1.2
fMUAThres = 3.5;

aiNumSpikes = zeros(1,length(acUnits));
afMUA = zeros(1,length(acUnits));
afMaxStd = zeros(1,length(acUnits));
afAmpRange = zeros(1,length(acUnits));
abNoData = zeros(1,length(acUnits)) > 0;
for k=1:length(acUnits)
    if ~isfield(acUnits{k},'m_afISIDistribution') || ~isfield(acUnits{k},'m_afSpikeTimes') 
        abNoData(k) = true;
        continue;
    end
    aiNumSpikes(k) = length(acUnits{k}.m_afSpikeTimes);
    afMUA(k) = sum(acUnits{k}.m_afISIDistribution(1:3))/  sum(acUnits{k}.m_afISIDistribution) * 100;
    afAmpRange(k) = max(acUnits{k}.m_afAvgWaveForm)-min(acUnits{k}.m_afAvgWaveForm);
    afMaxStd(k) = max(acUnits{k}.m_afStdWaveForm);
    
    fReal = mean(acUnits{k}.m_afAvgFirintRate_Stimulus(1:16));
    fArtificial = median(acUnits{k}.m_afAvgFirintRate_Stimulus(97:529));
    afRealToArtificialRatio(k) = fArtificial / fReal;
end

acUnits = acUnits(~abNoData & aiNumSpikes > 500 & afMaxStd./afAmpRange < fQuality); % This clears up most of the junk units
% The MUA was not found to be a reliable measure and many good units were
% thrown away...

aiSelectedUnits = fnFindUnitsWithStandardParam(acUnits);
if bUseStandardParamOnly
    acUnits = acUnits(aiSelectedUnits);
end

abRocco = zeros(1,length(acUnits));
for k=1:length(acUnits)
    abRocco(k) = strcmpi(acUnits{k}.m_strSubject,'Rocco');
end
fprintf('We recorded from %d single units (%d in Houdini and %d in Rocco)\n', length(acUnits),sum(~abRocco),sum(abRocco));

[aiFaceSelectivityIndex,afFaceSelectivityIndexUnBounded,afdPrime,afdPrimeBaselineSub,afDPrimeAllTrials]  = fnComputeFaceSelecitivyIndex(acUnits);
%% 