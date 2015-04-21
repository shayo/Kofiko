function fnAverageVol(acInputs, strOutput)
fprintf('Accumulating...');
strctVolAcc = MRIread(acInputs{1});
for k=2:length(acInputs)
    fprintf('*');
    strctVol = MRIread(acInputs{1});
    strctVolAcc.vol = strctVolAcc.vol + strctVol.vol;
end
strctVolAcc.vol = strctVolAcc.vol/ length(acInputs);
MRIwrite(strctVolAcc,strOutput);
fprintf(' Done!\n');
return;


        