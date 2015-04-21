
acFiles = fnReadImageList('\\kofiko-23b\StimulusSet\Monkey_Bodyparts\StandardFOB_v4_inv.txt');
for k=1:length(acFiles)
   I=imread(acFiles{k});
   C = I(25:80,29:70);
   [strPath,strFile] = fileparts(acFiles{k});
   imwrite(C,[strPath,'\cropped_',strFile,'.bmp']);
end
