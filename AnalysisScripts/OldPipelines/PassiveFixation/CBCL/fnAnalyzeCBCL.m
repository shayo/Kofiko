function strctUnit = fnAnalyzeCBCL(strctUnit, strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

load('CBCL_Models.mat');                 

[strctStat.m_afResFace_Sinha, strctStat.m_afResNonFace_Sinha] = fnFiringRateNumberOfCorrectRatios(strctUnit, aiNumCorrectPairsInFaces_Sinha,aiNumCorrectPairsInNonFaces_Sinha);
[strctStat.m_afResFace_Human, strctStat.m_afResNonFace_Human] = fnFiringRateNumberOfCorrectRatios(strctUnit, aiNumCorrectPairsInFaces_Human,aiNumCorrectPairsInNonFaces_Human);
[strctStat.m_afResFace_Monkey, strctStat.m_afResNonFace_Monkey] = fnFiringRateNumberOfCorrectRatios(strctUnit, aiNumCorrectPairsInFaces_Monkey,aiNumCorrectPairsInNonFaces_Monkey);


afAvgResponse = strctUnit.m_afAvgStimulusResponseMinusBaseline;
%afAvgResponse = strctUnit.m_afAvgFirintRate_Stimulus

afFacesRes = afAvgResponse(1:207);
afSortedFaceRes = sort(afFacesRes);

fPercentile = 0.9;

fPercentileRes = afSortedFaceRes(round(fPercentile*length(afFacesRes)));

afNonFaceRes = afAvgResponse(208:411);

strctStat.m_aiFalseAlarms = 207+find(afNonFaceRes > fPercentileRes);
strctStat.m_iNumFalseAlarms = length(strctStat.m_aiFalseAlarms);
fprintf('%d FA survived the %.2f percentile\n',strctStat.m_iNumFalseAlarms,fPercentile);


strctUnit.m_strctCBCL = strctStat;

return;

%%

% acFileNames = fnReadImageList('D:\Data\Doris\Stimuli\CMU_CBCL_Experiment\CMU_CBCL_Experiment.txt');
% a3iCBCLImages = zeros(100,100,411,'uint8');
% for k=1:411
%     a3iCBCLImages(:,:,k)=imread(acFileNames{k});
% end
% 
% save('Z:\AnalysisScripts\PassiveFixation\CBCL\CBCL_Images','a3iCBCLImages');
Tmp = mean(a3iCBCLImages(:,:,208:411),3)
figure;
imshow(Tmp,[]);



% % % 
% % % % Display an example from each category 
% % % if 0
% % %     acImageList=fnReadImageList('D:\Data\Doris\Stimuli\CMU_CBCL_Experiment\CMU_CBCL_Experiment.txt');
% % %     
% % %     figure(3);
% % %     clf;
% % %     for k=1:12
% % %         iIndex = find(aiNumCorrectSinhaInFaces == k,1,'first');
% % %         if ~isempty(iIndex)
% % %             tightsubplot(2,12,k,'Spacing',0.01);
% % %             I=imread(acImageList{iIndex});
% % %             imshow(I,[]);
% % %             title(sprintf('%d Correct',k));
% % %         end
% % %     end
% % %     for k=1:12
% % %         aiIndex = find(aiNumCorrectSinhaInNonFaces == k);
% % %         if ~isempty(aiIndex)
% % %             tightsubplot(2,12,12+k,'Spacing',0.01);
% % %             I=imread(acImageList{length(aiNumCorrectSinhaInFaces)+aiIndex(2)});
% % %             imshow(I,[]);
% % %             title(sprintf('%d Correct',k));
% % %         end
% % %     end
% % %     
% % %     figure(4);
% % %     clf;
% % %     for k=1:12
% % %         aiIndex = find(aiNumCorrectSinhaInFaces == k);
% % %         if ~isempty(aiIndex)
% % %             tightsubplot(2,12,k,'Spacing',0.01);
% % %             I = zeros(100,100);
% % %             for j=1:length(aiIndex)
% % %                 I = I + double(imread(acImageList{aiIndex(j)}));
% % %             end
% % %             imshow(I,[]);
% % %             title(sprintf('%d Correct',k));
% % %         end
% % %     end
% % %     
% % %     for k=1:12
% % %         aiIndex = find(aiNumCorrectSinhaInNonFaces == k);
% % %         if ~isempty(aiIndex)
% % %             tightsubplot(2,12,12+k,'Spacing',0.01);
% % %             I = zeros(100,100);
% % %             for j=1:length(aiIndex)
% % %                 I = I + double(imread(acImageList{length(aiNumCorrectSinhaInFaces)+aiIndex(j)}));
% % %             end
% % %             imshow(I,[]);
% % %             title(sprintf('%d Correct',k));
% % %         end
% % %     end
% % %     
% % % end
