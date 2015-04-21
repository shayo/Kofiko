function mcparams2extreg_exe(mcfile, extreg)
% mcc -o mcparams2extreg_exe -W main:mcparams2extreg_exe -T link:exe -d /home/helios/data/shayo/cooked/2010/101225Houdini_MyScripts/mcparams2extreg_proj/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v /home/helios/data/shayo/cooked/2010/101225Houdini_MyScripts/mcparams2extreg_exe.m 
%mcfile  = './data/bold/007/fmc.mcdat';
%extreg =  './data/bold/007/mcextreg';
nkeep     = [];
northog   = [6];
pctorthog = [];
monly     = 0;

mc = textread(mcfile);
mc = mc(:,2:7);
ntrs = size(mc,1);
if(ntrs < 6)
    fprintf('ERROR: ntrs = %d < 6\n',ntrs);
    if(~monly)
        fprintf('Quiting matlab\n');
        quit;
        fprintf('should not be here\n');
    end
end

if(~isempty(nkeep))
    x = mc(:,1:nkeep);
elseif(~isempty(northog))
    [u s v] = svd(mc);
    ds = diag(s);
    pct = 100*cumsum(ds)/sum(ds);
    x = u(:,1:northog);
    nkeep = northog;
    fprintf('INFO: northog = %d, pct = %g\n',northog,pct(nkeep));
else
    [u s v] = svd(mc);
    ds = diag(s);
    pct = 100*cumsum(ds)/sum(ds);
    nkeep = min(find(pct > pctorthog));
    x = u(:,1:nkeep);
    fprintf('INFO: pctorthog = %g, nkeep = %d\n',pctorthog,nkeep);
end

x2 = zeros(1,1,nkeep,ntrs);
x2(1,1,:,:) = x'; %'
%fmri_svbvolume(x2,extreg);

mri.vol = permute(x2,[1 3 2 4]);
mri.tr = 0;
mri.flip_angle = 0;
mri.te = 0;
mri.ti = 0;
mri.vox2ras0 = eye(4);
mri.xsize = 1;
mri.ysize = 1;
mri.zsize = 1;
mri.volres = [1 1 1];
mri.volsize = [size(mri.vol,1) size(mri.vol,2) size(mri.vol,3)];
fname = sprintf('%s.bhdr',extreg);
MRIwrite(mri,fname);
