strctTmp = load('CBCL_SelectedPerm.mat');
aiSelectedFacesInTrainingSet = strctTmp.aiFace;
aiSelectedNonFacesInTrainingSet = strctTmp.aiNonFace;

strctTmp = load('CBCL_SelectedPerm.mat');
aiNumCorrectPairsInFaces_Sinha = strctTmp.afSumTrainFaceAvg(strctTmp.aiFace);
aiNumCorrectPairsInNonFaces_Sinha = strctTmp.afSumTrainNonFaceAvg(strctTmp.aiNonFace);

load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\CBCL_For_Electrophsy_Data.mat');

strctMonkeyPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\MonkeyInvarianceRatios.mat');
strctShayPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\ShayInvarianceRatios.mat');

a2iPartRatio = nchoosek(1:11,2);
a2iCorrectEdgesMonkey = a2iPartRatio(strctMonkeyPred.aiInvarianceRatios(1:12),:);
a2iCorrectEdgesHuman = a2iPartRatio(strctShayPred.aiInvarianceRatios(1:12),:);


aiNumCorrectPairsInFaces_Monkey = sum(a2fAvgIntTrainFace(aiSelectedFacesInTrainingSet,a2iCorrectEdgesMonkey(:,1)) < ...
                              a2fAvgIntTrainFace(aiSelectedFacesInTrainingSet,a2iCorrectEdgesMonkey(:,2)), 2);
aiNumCorrectPairsInNonFaces_Monkey = sum(a2fAvgIntTrainNonFace(aiSelectedNonFacesInTrainingSet,a2iCorrectEdgesMonkey(:,1)) < ...
                              a2fAvgIntTrainNonFace(aiSelectedNonFacesInTrainingSet,a2iCorrectEdgesMonkey(:,2)), 2);

aiNumCorrectPairsInFaces_Human= sum(a2fAvgIntTrainFace(aiSelectedFacesInTrainingSet,a2iCorrectEdgesHuman(:,1)) < ...
                              a2fAvgIntTrainFace(aiSelectedFacesInTrainingSet,a2iCorrectEdgesHuman(:,2)), 2);
aiNumCorrectPairsInNonFaces_Human = sum(a2fAvgIntTrainNonFace(aiSelectedNonFacesInTrainingSet,a2iCorrectEdgesHuman(:,1)) < ...
                              a2fAvgIntTrainNonFace(aiSelectedNonFacesInTrainingSet,a2iCorrectEdgesHuman(:,2)), 2);
save('CBCL_Models','aiNumCorrectPairsInFaces_Monkey','aiNumCorrectPairsInNonFaces_Monkey',...
    'aiNumCorrectPairsInFaces_Human','aiNumCorrectPairsInNonFaces_Human','aiNumCorrectPairsInFaces_Sinha','aiNumCorrectPairsInNonFaces_Sinha');
