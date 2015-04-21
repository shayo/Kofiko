function fnInitializeParameterSweep()
global g_strctParadigm


pt2fStimulusPos = fnTsGetVar(g_strctParadigm, 'StimulusPos');
fStimulusSizePix = fnTsGetVar(g_strctParadigm, 'StimulusSizePix');
fRotationAngle = fnTsGetVar(g_strctParadigm, 'RotationAngle');
fStimulusON = fnTsGetVar(g_strctParadigm, 'StimulusON_MS');
fStimulusOFF = fnTsGetVar(g_strctParadigm, 'StimulusOFF_MS');

strctSweep = g_strctParadigm.m_astrctParameterSweepModes(g_strctParadigm.m_iParameterSweepMode);

g_strctParadigm.m_strctParamSweep.m_aiStimuli = 1:length(g_strctParadigm.m_strctDesign.m_astrctMedia);

if isempty(strctSweep.m_afX)
    g_strctParadigm.m_strctParamSweep.m_afXPos = pt2fStimulusPos(1);
else
    g_strctParadigm.m_strctParamSweep.m_afXPos = strctSweep.m_afX;
end

if isempty(strctSweep.m_afY)
    g_strctParadigm.m_strctParamSweep.m_afYPos = pt2fStimulusPos(2);
else
    g_strctParadigm.m_strctParamSweep.m_afYPos = strctSweep.m_afY;
end

if isempty(strctSweep.m_afSize)
    g_strctParadigm.m_strctParamSweep.m_afSize = fStimulusSizePix;
else
    g_strctParadigm.m_strctParamSweep.m_afSize = strctSweep.m_afSize;
end

if isempty(strctSweep.m_afTheta)
    g_strctParadigm.m_strctParamSweep.m_afTheta = fRotationAngle;
else
    g_strctParadigm.m_strctParamSweep.m_afTheta = strctSweep.m_afTheta;
end

if isempty(strctSweep.m_afStimulusON)
    g_strctParadigm.m_strctParamSweep.m_afStimulusON = fStimulusON;
else
    g_strctParadigm.m_strctParamSweep.m_afStimulusON = strctSweep.m_afStimulusON;
end


if isempty(strctSweep.m_afStimulusOFF)
    g_strctParadigm.m_strctParamSweep.m_afStimulusOFF = fStimulusOFF;
else
    g_strctParadigm.m_strctParamSweep.m_afStimulusOFF = strctSweep.m_afStimulusOFF;
end

acParamSpace = {[g_strctParadigm.m_strctParamSweep.m_aiStimuli],...
     [g_strctParadigm.m_strctParamSweep.m_afXPos],...
     [g_strctParadigm.m_strctParamSweep.m_afYPos],...
     [g_strctParadigm.m_strctParamSweep.m_afSize],...
     [g_strctParadigm.m_strctParamSweep.m_afTheta],...
     [g_strctParadigm.m_strctParamSweep.m_afStimulusON],...
     [g_strctParadigm.m_strctParamSweep.m_afStimulusOFF]};


%g_strctParadigm.m_a2fParamSpace = fnGenCombAux2(acParamSpace,zeros(1,5,'single'),1,zeros(prod(aiDimLen),5,'single'),1);
g_strctParadigm.m_a2fParamSpace = fnGenComb(acParamSpace);%,zeros(1,5,'single'),1,zeros(prod(aiDimLen),5,'single'),1);

if g_strctParadigm.m_bRandom
    aiSortInd = randperm(size(g_strctParadigm.m_a2fParamSpace,1));
    g_strctParadigm.m_a2fParamSpace = g_strctParadigm.m_a2fParamSpace(aiSortInd,:);
end
g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex = 1;
