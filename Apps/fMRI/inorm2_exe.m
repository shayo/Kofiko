function inorm2_exe(inputvolume, nskip, rthresh, maskfile)
% cd FuncPreproc
% mkdir inorm2_proj/src
% mcc -o inorm2_exe -W main:inorm2_exe -T link:exe -d inorm2_proj/src -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -v inorm2_exe.m 

[strPath, strFile, strExt] = fileparts(inputvolume);
meanvalfile = fullfile(strPath,[strFile,'.meanval']);

if ~exist('maskfile','var')
    maskfile = [];
end;

if ~exist('nskip','var')
    nskip = 0;
end

if ~exist('rthresh','var')
    rthresh = .75;
end

f = MRIread(inputvolume);
if(isempty(f))
  fprintf('ERROR: reading %s\n',inputvolume);
  if(~monly) quit; end
  return;
end

if(nskip > 0)
  if(nskip >= f.nframes)
    fprintf('ERROR: nskip=%d but only have %d frames\n',...
            nskip,f.nframes);
    if(~monly) quit; end
    return;
  end
  fprintf('INFO: skipping first %d frames\n',nskip);
  f.vol = f.vol(:,:,:,nskip+1:end);
end
f.nframes = size(f.vol,4);
fprintf('nframes = %d\n',f.nframes);

fmn = mean(f.vol,4);
if  (~isempty(maskfile))
  mask = MRIread(maskfile);
  if(isempty(mask))
    fprintf('ERROR: reading %s\n',maskfile);
    if(~monly) quit; end
    return;
  end
else
  fprintf('Constructing mask from mean image\n');
  gfmn = mean(fmn(:));
  athresh = rthresh * gfmn;
  mask.vol = fmn > athresh;
  %mask.vol = fast_dilate(mask.vol,1);
end
indmask = find(mask.vol);
nmask = length(indmask);
nvox = prod(f.volsize);
fprintf('Found %d/%d (%4.1f%%) voxels in mask\n',nmask,nvox,100*nmask/nvox);
if(nmask == 0) 
  fprintf('ERROR: no voxels found in mask\n');
  if(~monly) quit; end
  return;
end 

meanval = mean(fmn(indmask));
fprintf('In-Brain Mean Value is %g\n',meanval);

fp = fopen(meanvalfile,'w');
if(fp == -1)
  fprintf('ERROR: opening %s\n',meanvalfile);
  if(~monly) quit; end
  return;
end
fprintf(fp,'%f\n',meanval);
fclose(fp);
return;  
