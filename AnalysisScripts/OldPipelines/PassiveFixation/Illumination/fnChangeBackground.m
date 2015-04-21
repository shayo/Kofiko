strPath = 'C:\Shay\Data\StimulusSet\IlluminationSubSet\';
strPathOut = 'C:\Shay\Data\StimulusSet\IlluminationSubSet2\';
mkdir(strPathOut);
astrctDir = dir([strPath,'*.jpg']);
for k=1:length(astrctDir)
   I=imread([strPath,astrctDir(k).name]);
   B = I==28 | I == 29;
   B = imopen(imfill(~B,'holes') > 0,ones(2,2));
   J = I;
   J(~B) = 128;
    imwrite(J,[strPathOut,astrctDir(k).name]);
    figure(10);
    clf;
    imshow(J,[]);
    drawnow
    WaitSecs(0.2);
end

%%



strPath = 'C:\Shay\Data\StimulusSet\Illumination\Tmp2\';
astrctDir = dir([strPath,'*.jpg']);
for k=1:length(astrctDir)
    strNewName = astrctDir(k).name;
    strNewName(6) = [];
    movefile([strPath,astrctDir(k).name],[strPath,strNewName]);
end