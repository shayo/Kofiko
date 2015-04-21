function strctUnit = fnAnalyzeSinhaFOB(strctUnit, strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

return; % Drop all these units.
strctTmp = load('SinhaV1.mat');
a2iPerm = strctTmp.a2iAllPerm(1:242,:);
iStimOffset = 96;
iCatOffset = 6;
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};

a2iCorrectPairALargerB = [...
    1, 2;
    1, 4;
    5, 2;
    7, 4;
    3, 2;
    3, 4;
    3, 6;
    5, 9;
    7, 9;
    8, 9;
    10, 9;
    11, 9];

strctUnit = fnSinhaAnalysis(strctUnit, iStimOffset,iCatOffset,a2iPerm,acPartNames,a2iCorrectPairALargerB,strctConfig);

return;



