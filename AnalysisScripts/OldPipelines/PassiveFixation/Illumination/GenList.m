astrctFiles = dir('C:\Shay\Data\StimulusSet\Illumination\*.jpg');
hFileID = fopen('C:\Shay\Data\StimulusSet\Illumination\Illumination.txt','wb+');
aiID = zeros(1,length(astrctFiles));
aiAngle = zeros(1,length(astrctFiles));
aiIllumination = zeros(1,length(astrctFiles));
for j=1:length(astrctFiles)
    aiSep = find(astrctFiles(j).name == '_');
    aiID(j) = str2num(astrctFiles(j).name(1:aiSep(1)-1));
    aiAngle(j) = str2num(astrctFiles(j).name(aiSep(1)+1:aiSep(2)-1));
    aiIllumination(j) = str2num( astrctFiles(j).name(aiSep(4)+1:aiSep(5)-1));
    fprintf(hFileID,'%s\r\n',astrctFiles(j).name);
end
fclose(hFileID);

iNumStimuli = length(astrctFiles);
iNumCat = 6;
a2bStimulusCategory = zeros(iNumStimuli,iNumCat)>0;
a2bStimulusCategory(:,1) = aiAngle == 0;
a2bStimulusCategory(:,2) = aiAngle == -32;
a2bStimulusCategory(:,3) = aiAngle == 32;
a2bStimulusCategory(:,4) = aiAngle == 0 & aiIllumination == 0;
a2bStimulusCategory(:,5) = aiAngle == 0 & aiIllumination == 30;
a2bStimulusCategory(:,6) = aiAngle == 0 & aiIllumination == 90;
acCatNames = {'Frontal','ProfileL','ProfileR','F_Illum0','F_Illum30','F_Illum90'};

save('C:\Shay\Data\StimulusSet\Illumination\Illumination_Cat.mat','a2bStimulusCategory','acCatNames');
