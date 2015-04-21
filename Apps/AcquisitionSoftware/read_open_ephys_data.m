function [all_data, timestamps,nData,fSamplingRate, aftime] = read_open_ephys_data(filename)
strExpectedHeader = 'THIS IS A HEADER.';
fSamplingRate=25000;
fid = fopen(filename);

fseek(fid,0,'eof');
iFileSize = ftell(fid);

strHeader = fread(fid, length(strExpectedHeader),'char=>char')';
if ~strcmp(strExpectedHeader, strHeader)
    fseek(fid,0,'bof'); % no header
end

all_data = [];
timestamps= [];
aftime = [];
n=1;
while ~feof(fid)
    ts =  fread(fid, 1, 'double=>double');
    if isempty(ts)
        break;
    end
%     timestamps(n) = ts;
    timestamps(n)=ts;
    nsamples = fread(fid, 1, 'int32=>double');
%     fprintf('ts=%ld, N=%d\n',ts,nsamples);
aftime = [aftime,ts+(0:nsamples -1)/fSamplingRate];
    nData(n)=nsamples;
    [data,cnt] = fread(fid, nsamples, 'int16=>int16');
    all_data=[all_data;data];
    n=n+1;
    
end

fclose(fid);