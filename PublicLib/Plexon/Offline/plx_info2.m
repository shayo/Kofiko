function [tscounts, wfcounts, evcounts] = plx_info2(filename, fullread)
% plx_info(filename, fullread) -- read and display .plx file info
%
% [tscounts, wfcounts] = plx_info(filename, fullread)
%
% INPUT:
%   filename - if empty string, will use File Open dialog
%   fullread - if 0, reads only the file header
%              if 1, reads all the file
% OUTPUT:
%   tscounts - numunitsx130 array of timestamp counts
%      tscounts(i, j) is the number of timestamps for channel i, unit j
%   wfcounts - numunitsx130 array of waveform counts
%     wfcounts(i, j) is the number of waveforms for channel i, unit j
%  where numunits is 5 for fullread=0, 26 for fullread=1
%   evcounts - 1x512 array of external event counts
%     evcounts(i) is the number of events for channel i
global g_bVERBOSE

fid = fopen(filename, 'r');

if(fid == -1)
	disp('cannot open file');
   return
end

if g_bVERBOSE
    disp(strcat('file = ', filename));
end
header = fread(fid, 64, 'int32');
version = header(2);
freq = header(35);  % frequency
ndsp = header(36);  % number of dsp channels
nevents = header(37); % number of external events
nslow = header(38);  % number of slow channels
npw = header(39);  % number of points in wave
npr = header(40);  % number of points before threshold
if g_bVERBOSE

disp(strcat('version = ', num2str(version)));
disp(strcat('frequency = ', num2str(freq)));
disp(strcat('number of DSP headers = ', num2str(ndsp)));
disp(strcat('number of Event headers = ', num2str(nevents)));
disp(strcat('number of A/D headers = ', num2str(nslow)));
end
tscounts = fread(fid, [5, 130], 'int32');
wfcounts = fread(fid, [5, 130], 'int32');
evcounts = fread(fid, [1, 512], 'int32');
if fullread > 0
   % reset counters
   tscounts = zeros(26, 130);
   wfcounts = zeros(26, 130);
   evcounts = zeros(1, 512);
   % skip variable headers
   fseek(fid, 1020*ndsp + 296*nevents + 296*nslow, 'cof');
	record = 0;
	while feof(fid) == 0
   	type = fread(fid, 1, 'int16');
		upperbyte = fread(fid, 1, 'int16');
		timestamp = fread(fid, 1, 'int32');
		channel = fread(fid, 1, 'int16');
   	unit = fread(fid, 1, 'int16');
	   nwf = fread(fid, 1, 'int16');
   	nwords = fread(fid, 1, 'int16');
	   toread = nwords;
   	if toread > 0
      	wf = fread(fid, toread, 'int16');
      end
      if type == 1
         tscounts(unit+1, channel+1) = tscounts(unit+1, channel+1) + 1;
         if toread > 0
            wfcounts(unit+1, channel+1) = wfcounts(unit+1, channel+1) + 1;
            end
      end
      if type == 4
         evcounts(channel+1) = evcounts(channel+1) + 1;
      end
      
   	record = record + 1;
	   if feof(fid) == 1
   	   break
	   end
    end
  
end

fclose(fid);