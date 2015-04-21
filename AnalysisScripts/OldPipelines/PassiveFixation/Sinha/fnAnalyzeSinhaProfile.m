function strctUnit = fnAnalyzeSinhaProfile(strctUnit, strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

strctTmp = load('Sinha_Profile.mat');
a2iPerm = strctTmp.a2iAllPerm;
iStimOffset = 96;
iCatOffset = 6;
acPartNames = {'Nose','Mouth','Up Lip','Forehead','Chin','L Cheek','R Cheek','R Eye','L Eye','L Eyebrow','R Eyebrow'};


a2iCorrectPairsALargerB =[
     1     2
     1     8
     1     9
     1    11
     5     2
     6     2
     3     8
     4     8
     6     5
     5     8
     6     8
     6     9
     6    11
     9     8
    10     8];

strctUnit = fnSinhaAnalysis(strctUnit, iStimOffset,iCatOffset,a2iPerm,acPartNames,a2iCorrectPairsALargerB,strctConfig);
return;