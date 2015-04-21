addpath('w:\mex\x64');
% X=textread('W:\MEX_Code\KlustaKwikMatlabWrapper\Win32\Release\lynn.fet.1');
% Y=textread('W:\MEX_Code\KlustaKwikMatlabWrapper\Win32\Release\lynn.clu.1');
% NumDim = X(1,1);
% NumSpikes = size(X,1)-1;
% a2fFeatures = X(2:end,1:end-1);
% 
% Clusters = unique(Y);
% figure(11);
% clf;
% hold on;
% a2fColors = lines(length(Clusters))
% for k=1:length(Clusters)
%     plot(a2fFeatures(Y(2:end) == Clusters(k),:)','color',a2fColors(k,:));
% end;
%%

% Generate two nicely separated gaussians...
N=50;
X1=randn(N);
Y1=randn(N);

X2=randn(N)*2+5;
Y2=randn(N);

figure(12);
clf;hold on;
plot(X1,Y1,'b.');
plot(X2,Y2,'r.');

axis([-20 20 -20 20]);

X=[X1(:);X2(:)];
Y=[Y1(:);Y2(:)];
% Dump to file
a2fFeatures = [X,Y];
    
fprintf('Dumping spike data...');
hFileID = fopen('C:\test.fet.1','w+');
iNumFeatures = size(a2fFeatures,2) ; % adding Time as the extra feature...
iNumSpikes = size(a2fFeatures,1) ;
fprintf(hFileID,'%d\r\n',iNumFeatures);
for iSpikeIter=1:iNumSpikes
    if mod(iSpikeIter,100) == 0
        fprintf('%d out of %d\n',iSpikeIter,iNumSpikes);
    end
    for iDimIter=1:iNumFeatures
        fprintf(hFileID,'%d ',a2fFeatures(iSpikeIter, iDimIter));
    end
    fprintf(hFileID,'\r\n');
end
fclose(hFileID);
fprintf('Done!\n');
system('W:\MEX_Code\KlustaKwikMatlabWrapper\Win32\Release\KlustaKwik.exe C:\test 1 -MinClusters 1 -MaxClusters 10 -Verbose 0 -nStarts 1'); % -MinClusters 1 -MaxClusters 5
dbg = 1;

Z=textread('C:\test.clu.1');
NumClusters = Z(1);
Clusters = unique(Z);
figure(11);
clf;
hold on;
a2fColors = lines(length(Clusters));
for k=1:length(Clusters)
    plot(a2fFeatures(Z(2:end) == Clusters(k),1),a2fFeatures(Z(2:end) == Clusters(k),2),'.','color',a2fColors(k,:));
end;
axis([-20 20 -20 20]);
%%
aiClusterAssignment = KlustaKwikMatlabWrapper(a2fFeatures',[],'Screen',0,'MinClusters',1,'MaxClusters',10);
Clusters = unique(aiClusterAssignment)

figure(15);
clf;
hold on;
a2fColors = lines(length(Clusters));
for k=1:length(Clusters)
    plot(a2fFeatures(aiClusterAssignment == Clusters(k),1),a2fFeatures(aiClusterAssignment == Clusters(k),2),'.','color',a2fColors(k,:));
end;
axis([-20 20 -20 20]);
