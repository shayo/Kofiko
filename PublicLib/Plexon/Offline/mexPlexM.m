function [varargout] = mexPlexM(sub_command, filename, varargin)
%MEXPLEX emulate the functions from Plexon's mexPlex.dll as mexPlex.m so it
%will work on the macintosh.
%   I will only bother to reverse engineer functions I actually need, but
%   the function prototypes are from the current mexPlex as distributed by Plexon
%	(ReadingPLXandDDTFilesinMatlab609)
% TODO:
%	allow to only read in data between specified timepoints
%	check output of mexPlex.dll for dimensionality (needs to be done for each sub function...)
%	implement minimal set to run analysis
%	implement plx file splitting, needs fixup of headers and proper sorting
%		of data blocks (use fposmap)
%	implement non-plexon sub_commands as strings so namespaces do not clash
%	TETRODES: allinternal data structure will have to be reconsidered
%	switch plx_read_data to return sipke and ad data separated for existing
%		channels
% DONE:
%	figure out how to deal with variable input and output argument lists
%	keep a table of fileoffses to relevant structures in the plx file

% reserve some "permanent" storage for the current file name
persistent last_filename last_filename_stat
% headers, headers, headers ...
persistent PL_FileHeader PL_ChanHeader PL_EventHeader PL_SlowChannelHeader chan_names chan_SIGnames event_names slowchannel_names PLX_header
% TODO figure out the best internal representation of the file data
persistent spike event ad fposmap

debug = 0;
try
	if(nargin < 2)
		disp('mexPlex requires a minimum of 2 input arguments, command_index and filename')
		return
	end
	% accept the empty string '' and bring up a loading dialog
	if(length(filename) == 0)
		[fname, pathname] = uigetfile('*.plx', 'Select a .plx file');
		filename = strcat(pathname, fname);
	end

	% stat the file (we want size and dates)
	filename_stat = dir(filename);

	% open the data file (enforce little endianess)
	[fid, message] = fopen(filename, 'r', 'l');
	if(fid == -1)
		disp(['Cannot open file: ', filename]);
		disp(message);
		return
	end

	read_plx = 0;
	% only read in the file's header information once, use filename and
	% size and date as heuristics
	if ~(strcmp(last_filename, filename)),
		% new file name
		read_plx = 1;
	elseif (last_filename_stat.bytes ~= filename_stat.bytes)
		% size of file differs (old headers should be okay but to be safe)
		read_plx = 1;
	end

	% remember the current file for future calls
	last_filename = filename;
	last_filename_stat = filename_stat;

	% read in the headers of the plx file and create maps of fseek offsets
	% pointing to the relevant data structures of the plx file...
	if (read_plx),
		disp('Parsing header information of .plx file...');
		% TODO check file size versus header size before trying to read
		% beyond EOF but that is mainly cosmetic right now
		% parse the PL_FileHeader
		PL_FileHeader = plx_read_PL_FileHeader(fid);
		% parse PL_ChanHeader * NumDSPChannels
		for i_ChanHeader = 1 : double(PL_FileHeader.NumDSPChannels)
			if (i_ChanHeader == 1),
				PL_ChanHeader = plx_read_PL_ChanHeader(fid);
			else
				PL_ChanHeader(i_ChanHeader) = plx_read_PL_ChanHeader(fid);
			end
			chan_names(i_ChanHeader, 1:32) = PL_ChanHeader(1, i_ChanHeader).Name(1:32);
			chan_SIGnames(i_ChanHeader, 1:32) = PL_ChanHeader(1, i_ChanHeader).SIGName(1:32);
		end
		% parse PL_EventHeader * NumEventChannels
		for i_EventHeader = 1 : double(PL_FileHeader.NumEventChannels)
			if (i_EventHeader == 1),
				PL_EventHeader = plx_read_PL_EventHeader(fid);
			else
				PL_EventHeader(i_EventHeader) = plx_read_PL_EventHeader(fid);
			end
			event_names(i_EventHeader, 1:32) = PL_EventHeader(1, i_EventHeader).Name(1:32);
		end
		% parse PL_SlowChannelHeader * NumSlowChannels
		for i_SlowChannelHeader = 1 : double(PL_FileHeader.NumSlowChannels)
			if (i_SlowChannelHeader == 1),
				PL_SlowChannelHeader = plx_read_PL_SlowChannelHeader(fid);
			else
				PL_SlowChannelHeader(i_SlowChannelHeader) = plx_read_PL_SlowChannelHeader(fid);
			end
			slowchannel_names(i_SlowChannelHeader, 1:32) = PL_SlowChannelHeader(1, i_SlowChannelHeader).Name(1:32);
		end

		PLX_header.PL_FileHeader = PL_FileHeader;
		PLX_header.PL_ChanHeader = PL_ChanHeader;
		PLX_header.PL_EventHeader = PL_EventHeader;
		PLX_header.PL_SlowChannelHeader = PL_SlowChannelHeader;
	end

	% parse the data file only once, and extract all relevant information,
	% later calls will massage the raw data into whatever the sub_command
	% should return... try to only read in the data if really required...
	if ismember(sub_command, [2 3 5 6]) && (read_plx || isempty(spike) || isempty(spike.ts))
		spike = [];
		event = [];
		ad = [];
		fposmap = [];
		opts.spike_event_ad = 1;	% do type specific prcossesing, if zero spike, event and ad stay empty
		opts.spike_wf = 1;			% extract the spike waveforms, 0 only good for debugging
		opts.ad_wf = 1;				% extract continuous data, 0 only good for debugging
		opts.fposmap = 0;			% extract a map of data header filepositions (includes channel and unit)
		disp('Parsing data from .plx file...');
		[spike, event, ad, fposmap] = plx_read_data(fid, PLX_header, opts);
	end
	
% 	% for debugging
% 	save(fullfile(pwd, 'tmp_091222_out.mat'), 'filename', 'PL_FileHeader', 'PL_ChanHeader', 'PL_EventHeader', 'PL_SlowChannelHeader', 'spike', 'event', 'ad', 'fposmap', 'chan_names', 'chan_SIGnames', 'event_names', 'slowchannel_names', 'PLX_header');
% 	load(fullfile(pwd, 'tmp_091222_out.mat'));
	

	
	% plexon defined
	switch sub_command
		case 1	% ddt
			% function [nch, npoints, freq, d] = local_ddt(filename)
			func_description = 'ddt(filename) Read data from a .ddt file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 2	%plx_ad
			% function [adfreq, n, ts, fn, ad] = local_plx_ad(filename, ch)
			% func_description = 'plx_ad(filename, channel): Read a/d data from a .plx file';
			[varargout{1}, varargout{2}, varargout{3}, ...
				varargout{4}, varargout{5}] = local_plx_ad(varargin{1}, ad, PL_SlowChannelHeader, double(PLX_header.PL_FileHeader.ADFrequency));

		case 3	% plx_event_ts
			% function [n, ts, sv] = local_plx_event_ts(filename, ch)
			% func_description = 'plx_event_ts(filename, channel) Read event timestamps from a .plx file';
			[varargout{1}, varargout{2}, varargout{3}] = local_plx_event_ts(varargin{1}, event, double(PLX_header.PL_FileHeader.ADFrequency));

		case 4	% plx_info
			% function  [tscounts, wfcounts, evcounts] = local_plx_info(filename, fullread)
			func_description = 'plx_info(filename, fullread) -- read and display .plx file info';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 5	% plx_ts
			% function [n, ts] = local_plx_ts(filename, channel, unit)
			% func_description = 'plx_ts(filename, channel, unit): Read spike timestamps from a .plx file';
			[varargout{1}, varargout{2}] = local_plx_ts(varargin{1}, varargin{2}, spike, double(PLX_header.PL_FileHeader.ADFrequency));
			
		case 6	% plx_waves
			% function [n, npw, ts, wave] = local_plx_waves(filename, ch, u)
			% func_description = 'plx_waves(filename, channel, unit): Read waveform data from a .plx file';
			[varargout{1}, varargout{2}, varargout{3}, varargout{4}] = local_plx_waves(varargin{1}, varargin{2}, spike, double(PLX_header.PL_FileHeader.ADFrequency));

		case 7	%plx_ad_span
			% function [adfreq, n, ad] = local_plx_ad_span(filename, ch, startCount,endCount)
			func_description = 'plx_ad_span(filename, channel): Read a span of a/d data from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 8	%plx_chan_gains
			% function [n,gains] = local_plx_chan_gains(filename)
			func_description = 'plx_chan_gains(filename): Read channel gains from .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 9	%plx_chan_thresholds
			% function [n,thresholds] = local_plx_chan_thresholds(filename)
			func_description = 'plx_chan_thresholds(filename): Read channel thresholds from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 10	%plx_chan_filters
			% function [n,filters] = local_plx_chan_filters(filename)
			func_description = 'plx_chan_filters(filename): Read channel filter settings for each spike channel from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 11	%plx_adchan_gains
			% function [n,gains] = local_plx_adchan_gains(filename)
			func_description = 'plx_adchan_gains(filename): Read analog channel gains from .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 12	%plx_adchan_freqs
			% function [n,freqs] = local_plx_adchan_freqs(filename)
			func_description = 'plx_adchan_freq(filename): Read the per-channel frequencies for analog channels from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 13	%plx_information
			%[OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreTresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = local_plx_information(filename, PL_FileHeader);
			%func_description = 'plx_information(filename) -- read extended header infromation from a .plx file';
			[varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, ...
				varargout{8}, varargout{9}, varargout{10}, varargout{11}, varargout{12}, varargout{13}] = local_plx_information(filename, PL_FileHeader);

		case 14	%plx_chan_names
			% function [n,names] = local_plx_chan_names(filename)
			%func_description = 'plx_chan_names(filename): Read name for each spike channel from a .plx file';
			[varargout{1}, varargout{2}] = local_plx_chan_names(PL_FileHeader, chan_names, chan_SIGnames);

		case 15	%plx_adchan_names
			% function [n,names] = local_plx_adchan_names(filename)
			%func_description = 'plx_adchan_names(filename): Read name for each a/d channel from a .plx file';
			[varargout{1}, varargout{2}] = local_plx_adchan_names(PL_FileHeader, slowchannel_names);

		case 16	%plx_event_names
			% [n,names] = local_plx_event_names(filename)
			%func_description = 'plx_event_names(filename): Read name for each event type from a .plx file';
			[varargout{1}, varargout{2}] = local_plx_event_names(PL_FileHeader, event_names);

		case 17	%plx_ad_v
			% function [adfreq, n, ts, fn, ad] = local_plx_ad_v(filename, ch)
			func_description = 'plx_ad_v(filename, channel): Read a/d data from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 18	%plx_ad_span_v
			% function [adfreq, n, ad] = local_plx_ad_span_v(filename, ch, startCount,endCount)
			func_description = 'plx_ad_span_v(filename, channel): Read a span of a/d data from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 19	%plx_waves_v
			% function [n, npw, ts, wave] = local_plx_waves_v(filename, ch, u)
			func_description = 'plx_waves_v(filename, channel, unit): Read waveform data from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 20	%ddt_v
			% function [nch, npoints, freq, d] = local_ddt_v(filename)
			func_description = 'ddt_v(filename) Read data from a .ddt file returning samples in mV';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 21	%plx_vt_interpret
			% function [nCoords, nDim, nVTMode, c] = local_plx_vt_interpret(ts, sv);
			func_description = 'plx_vt_interpret - interpret CinePlex video tracking data';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 22	%plx_close
			% function [n] = local_plx_close(filename)
			%func_description = 'plx_close(filename): Close the .plx file';
			[varargout{1}] = local_plx_close(filename, fid);
			% make sure we return the memory we hogged to be quick...
			clear last_filename last_filename_stat
			clear PL_FileHeader PL_ChanHeader PL_EventHeader PL_SlowChannelHeader chan_names chan_SIGnames event_names slowchannel_names PLX_header
			clear spike event ad fposmap
			return

		case 23	%plx_adchan_samplecounts
			% function [n,samplecounts] = local_plx_adchan_samplecounts(filename)
			func_description = 'plx_adchan_samplecounts(filename): Read the per-channel sample counts for analog channels from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 24	%plx_ad_gap_info
			% function [adfreq, n, ts, fn] = local_plx_ad_gap_info(filename, ch)
			func_description = 'plx_ad_gap_info(filename, channel): Read a/d info from a .plx file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 25	%ddt_write_v
			% function [errCode] = local_ddt_write_v(filename, nch, npoints, freq, d)
			func_description = 'ddt_write_v(filename, nch, npoints, freq, d) Write data to a .ddt file';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 26	%plx_chanmap
			% function  [n,dspchans] = local_plx_chanmap(filename)
			func_description = 'plx_chanmap(filename) -- return map of raw DSP channel numbers for each channel';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		case 27	%plx_ad_chanmap
			% function  [n,adchans] = local_plx_ad_chanmap(filename)
			func_description = 'plx_ad_chanmap(filename) -- return map of raw continuous channel numbers for each channel';
			disp([num2str(sub_command), ' : ', func_description, '. not yet implemented...']);

		otherwise
			disp(['Subcommand number: ', num2str(sub_command), ' is beyond what I know about plexMex.dll, so I simply ignore it...']);
	end

	% clean up, should we really enforce this or only close on
	fclose(fid)

catch ME
	% ME is a 'magic' object, so the name has to be ME... (MatlabException?)
	disp ('Exception caught, cleaning up...');

	% house keeping
	fclose(fid);

	% what went wrong?
	if (debug),
		ME
		ME.message
		ME.stack.file
		ME.stack.name
		ME.stack.line
	end

	% erm, what was it that went wrong, and where?
	rethrow(ME);
end

return


%%
% function [nch, npoints, freq, d] = local_ddt(filename)
% % ddt(filename) Read data from a .ddt file
% %
% % [nch, npoints, freq, d] = ddt(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %
% % OUTPUT:
% %   nch - number of channels
% %   npoints - number of data points for each channel
% %   freq - A/D frequency
% %   d - [nch npoints] data array
% [nch, npoints, freq, d] = mexPlex(1,filename);


%%
function [adfreq, n, ts, fn, ad_out] = local_plx_ad(channel, ad, PL_SlowChannelHeader, ADFrequency_ticks_per_sec)
% % plx_ad(filename, channel): Read a/d data from a .plx file
% %
% % [adfreq, n, ts, fn, ad] = plx_ad(filename, ch)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 0-based channel number
% %
% %           a/d data come in fragments. Each fragment has a timestamp
% %           and a number of a/d data points. The timestamp corresponds to
% %           the time of recording of the first a/d value in this fragment.
% %           All the data values stored in the vector ad.
% %
% % OUTPUT:
% %   adfreq - digitization frequency for this channel
% %   n - total number of data points
% %   ts - array of fragment timestamps (one timestamp per fragment, in seconds)
% %   fn - number of data points in each fragment
% %   ad_out - array of raw a/d values
%
% [adfreq, n, ts, fn, ad] = mexPlex(2,filename, ch);
adfreq = double(PL_SlowChannelHeader(channel + 1).ADFreq);

ts = double(ad.fragment_ts) / ADFrequency_ticks_per_sec;
n_fragments = length(ts);
fn = zeros([n_fragments 1]);

% slow_channel_ts_idx = find(ad.short(:, 1) == channel);
slow_channel_wf_idx = find(ad.wf(:, 2) == channel);
if ~isempty(slow_channel_wf_idx),
	ad_tmp = ad.wf(slow_channel_wf_idx, :);
	ad_out = double(ad_tmp(:, 1));
else
	disp(['No ad data for channel ', num2str(channel), '.']);
	ad_out = [];
	fn = zeros([n_fragments, 1]);
end
for i_fragment = 1 : n_fragments,
	tmp_idx = find(ad_tmp(:, 3) == i_fragment);
	fn(i_fragment) = length(tmp_idx);
end
n = length(ad_out);
return


%%
function [n, ts, sv] = local_plx_event_ts(event_channel, event, ADFrequency_ticks_per_sec)
% % plx_event_ts(filename, channel) Read event timestamps from a .plx file
% %
% % [n, ts, sv] = plx_event_ts(filename, channel)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 1-based external channel number
% %             strobed channel has channel number 257
% % OUTPUT:
% %   n - number of timestamps
% %   ts - array of timestamps (in seconds)
% %   sv - array of strobed event values (filled only if channel is 257)
%
% [n, ts, sv] = mexPlex(3,filename, ch);
n = 0;
ts = [];
sv = [];
event_channel_idx = find(event.short(:, 1) == event_channel);
if ~isempty(event_channel_idx);
	n = length(event_channel_idx);
	ts = double(event.ts(event_channel_idx)) / ADFrequency_ticks_per_sec;
	sv = double(event.short(event_channel_idx, 2));	% only valid for event_channel == 257
else
	disp(['No Timestamps for event ', num2str(event_channel), '.']);
end
return

%%
% function  [tscounts, wfcounts, evcounts] = local_plx_info(filename, fullread)
% % plx_info(filename, fullread) -- read and display .plx file info
% %
% % [tscounts, wfcounts, evcounts] = plx_info(filename, fullread)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   fullread - if 0, reads only the file header
% %              if 1, reads the entire file
% % OUTPUT:
% %   tscounts - 2-dimensional array of timestamp counts for each unit
% %      tscounts(i, j) is the number of timestamps for channel j-1, unit i
% %                                (see comment below)
% %   wfcounts - 2-dimensional array of waveform counts for each unit
% %     wfcounts(i, j) is the number of waveforms for channel j-1, unit i
% %                                (see comment below)
% %   evcounts - 1x512 array of external event counts
% %     evcounts(i) is the number of events for event channel i
% %
% % Note that for tscounts, wfcounts, the unit,channel indices i,j are off by one.
% % That is, for channels, the count for channel n is at index n+1, and for units,
% %  index 1 is unsorted, 2 = unit a, 3 = unit b, etc
% % The dimensions of the tscounts and wfcounts arrays are
% %   (NChan+1) x (MaxUnits+1)
% % where NChan is the number of channel headers in the plx file, and
% % MaxUnits is 4 if fullread is 0, or 26 if fullread is 1. This is because
% % the header of a .plx file can only accomodate 4 units, but doing a
% % fullread on the file may show that there are actually up to 26 units
% % present in the file.
%
% [tscounts, wfcounts, evcounts] = mexPlex(4,filename, fullread);


%%
function [n, ts] = local_plx_ts(channel, unit, spike, ADFrequency_ticks_per_sec)
% % plx_ts(filename, channel, unit): Read spike timestamps from a .plx file
% %
% % [n, ts] = plx_ts(filename, channel, unit)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 1-based channel number
% %   unit  - unit number (0- unsorted, 1-4 units a-d)
% % OUTPUT:
% %   n - number of timestamps
% %   ts - array of timestamps (in seconds)
%
% [n, ts] = mexPlex(5,filename, channel, unit);
n = 0;
ts = [];
spike_channel_idx = find(spike.short(:, 1) == channel);
spike_unit_idx = find(spike.short(:, 2) == unit);
spike_channel_unit_idx = intersect(spike_channel_idx, spike_unit_idx);

if ~isempty(spike_channel_unit_idx),
	n = length(spike_channel_unit_idx);
	ts = double(spike.ts(spike_channel_unit_idx)) / ADFrequency_ticks_per_sec;
else
	disp(['No Timestamps for channel ', num2str(channel), ' and unit ', num2str(unit), '.']);	
end
return


%%
function [n, npw, ts, wave] = local_plx_waves(channel, unit, spike, ADFrequency_ticks_per_sec)
% % plx_waves(filename, channel, unit): Read waveform data from a .plx file
% %
% % [n, npw, ts, wave] = plx_waves(filename, channel, unit)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 1-based channel number
% %   unit  - unit number (0- unsorted, 1-4 units a-d)
% % OUTPUT:
% %   n - number of waveforms
% %   npw - number of points in each waveform
% %   ts - array of timestamps (in seconds)
% %   wave - array of waveforms [npw, n], raw a/d values
%
% [n, npw, ts, wave] = mexPlex(6,filename, ch, u);
n = 0;
npw = 0;
ts = [];
wave = [];
if ~isempty(spike.wf),
spike_channel_idx = find(spike.short(:, 1) == channel);
spike_unit_idx = find(spike.short(:, 2) == unit);
spike_channel_unit_idx = intersect(spike_channel_idx, spike_unit_idx);

if ~isempty(spike_channel_unit_idx),
	n = length(spike_channel_unit_idx);
	npw = size(spike.wf, 2);
	ts = double(spike.ts(spike_channel_unit_idx)) / ADFrequency_ticks_per_sec;
	wave = double(spike.wf(spike_channel_unit_idx, :));
else
	disp(['No Timestamps?Waveforms for channel ', num2str(channel), ' and unit ', num2str(unit), '.']);	
end
else
	disp(['No waveforms extracted/stored in .plx file.']);
end
return


%%
% function [adfreq, n, ad] = local_plx_ad_span(filename, ch, startCount,endCount)
% % plx_ad_span(filename, channel): Read a span of a/d data from a .plx file
% %
% % [adfreq, n, ad] = plx_ad_span(filename, ch,startCount,endCount)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   startCount - index of first sample to fetch
% %   endCount - index of last sample to fetch
% %   channel - 0 - based channel number
% %
% % OUTPUT:
% %   adfreq - digitization frequency for this channel
% %   n - total number of data points
% %   ad - array of raw a/d values
%
% [adfreq, n, ad] = mexPlex(7,filename, ch, startCount, endCount);


%%
% function [n,gains] = local_plx_chan_gains(filename)
% % plx_chan_gains(filename): Read channel gains from .plx file
% %
% % [gains] = plx_chan_gains(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %  gains - array of total gains
% %   n - number of channels
%
% [n,gains] = mexPlex(8,filename);


%%
% function [n,thresholds] = local_plx_chan_thresholds(filename)
% % plx_chan_thresholds(filename): Read channel thresholds from a .plx file
% %
% % [n,thresholds] = plx_chan_thresholds(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   thresholds - array of tresholds, expressed in raw A/D counts
% %   n - number of channel
%
% [n,thresholds] = mexPlex(9,filename);


%%
% function [n,filters] = local_plx_chan_filters(filename)
% % plx_chan_filters(filename): Read channel filter settings for each spike channel from a .plx file
% %
% % [n,filters] = plx_chan_filters(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   filter - array of filter values (0 or 1)
% %   n - number of channels
%
% [n,filters] = mexPlex(10,filename);


%%
% function [n,gains] = local_plx_adchan_gains(filename)
% % plx_adchan_gains(filename): Read analog channel gains from .plx file
% %
% % [n,gains] = plx_adchan_gains(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %  gains - array of total gains
% %  n - number of channels
%
% [n,gains] = mexPlex(11,filename);


%%
% function [n,freqs] = local_plx_adchan_freqs(filename)
% % plx_adchan_freq(filename): Read the per-channel frequencies for analog channels from a .plx file
% %
% % [n,freqs] = plx_adchan_freq(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   freqs - array of frequencies
% %   n - number of channels
%
% [n,freqs] = mexPlex(12,filename);


%%
function  [OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreTresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = local_plx_information(filename, PL_FileHeader)
% % plx_information(filename) -- read extended header infromation from a .plx file
% %
% % [OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreTresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = plx_information(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% % OpenedFileName    - returns the filename (useful if empty string is passed as filename)
% % Version -  version code of the plx file format
% % Freq -  timestamp frequency for waveform digitization
% % Comment - user-entered comment
% % Trodalness - 0,1 = single electrode, 2 = stereotrode, 4 = tetrode
% % Number of Points Per Wave - number of samples in a spike waveform
% % Pre Threshold Points - the sample where the threshold was crossed
% % SpikePeakV - peak voltage in mV of the final spike A/D converter
% % SpikeADResBits - resolution of the spike A/D converter (usually 12 bits)
% % SlowPeakV - peak voltage of mV of the final analog A/D converter
% % SlowADResBits - resolution of the analog A/D converter (usually 12 bits)
% % Duration - the duration of the file in seconds
% % DateTime - date and time string for the file
%
% [OpenedFileName, Version, Freq, Comment, Trodalness, NPW, PreTresh, SpikePeakV, SpikeADResBits, SlowPeakV, SlowADResBits, Duration, DateTime] = mexPlex(13,filename);

% properly cast the output to match what the mex file does
OpenedFileName = filename;									% returns the filename (useful if empty string is passed as filename)
Version = double(PL_FileHeader.Version);					%  version code of the plx file format
Freq = double(PL_FileHeader.ADFrequency);					% timestamp frequency for waveform digitization
Comment = PL_FileHeader.Comment;						% user-entered comment
Trodalness = double(PL_FileHeader.Trodalness);				% Trodalness				% 0,1 = single electrode, 2 = stereotrode, 4 = tetrode
NPW = double(PL_FileHeader.NumPointsWave);					% Number of Points Per Wave - number of samples in a spike waveform
PreTresh = double(PL_FileHeader.NumPointsPreThr);			% Pre Threshold Points - the sample where the threshold was crossed
SpikePeakV = double(PL_FileHeader.SpikeMaxMagnitudeMV);		% SpikePeakV - peak voltage in mV of the final spike A/D converter
SpikeADResBits = double(PL_FileHeader.BitsPerSpikeSample);	% SpikeADResBits - resolution of the spike A/D converter (usually 12 bits)
SlowPeakV = double(PL_FileHeader.SlowMaxMagnitudeMV);		% SlowPeakV - peak voltage of mV of the final analog A/D converter
SlowADResBits = double(PL_FileHeader.BitsPerSlowSample);	% SlowADResBits - resolution of the analog A/D converter (usually 12 bits)
Duration = double(PL_FileHeader.LastTimestamp / Freq);		% Duration - the duration of the file in seconds
DateTime = [num2str(PL_FileHeader.Month, '%02d'), '/', num2str(PL_FileHeader.Day, '%02d'), '/', num2str(PL_FileHeader.Year, '%04d'), ' ', num2str(PL_FileHeader.Hour, '%02d'), ':', num2str(PL_FileHeader.Minute, '%02d'), ':', num2str(PL_FileHeader.Second, '%02d')];		% DateTime - date and time string for the file

return


%%
function [n,names] = local_plx_chan_names(PL_FileHeader, chan_names, chan_SIGnames)
% % plx_chan_names(filename): Read name for each spike channel from a .plx file
% %
% % [n,names] = plx_chan_names(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   names - array of channel name strings
% %   n - number of channels
%
% [n,names] = mexPlex(14,filename);
%TODO: figure out which names the mexPlex uses...
tmp_names = chan_names;
names = sanitize_plx_names(tmp_names);
n = PL_FileHeader.NumDSPChannels;
return


%%
function [n,names] = local_plx_adchan_names(PL_FileHeader, slowchannel_names)
% % plx_adchan_names(filename): Read name for each a/d channel from a .plx file
% %
% % [n,names] = plx_adchan_names(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   names - array of a/d channel name strings
% %   n - number of channels
%
% [n,names] = mexPlex(15,filename);
names = sanitize_plx_names(slowchannel_names);
n = PL_FileHeader.NumSlowChannels;
return


%%
function [n,names] = local_plx_event_names(PL_FileHeader, event_names)
% % plx_event_names(filename): Read name for each event type from a .plx file
% %
% % [n,names] = plx_event_names(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   names - array of event name strings
% %   n - number of channels
%
% [n,names] = mexPlex(16,filename);
names = sanitize_plx_names(event_names);
n = PL_FileHeader.NumEventChannels;
return


%%
% function [adfreq, n, ts, fn, ad] = local_plx_ad_v(filename, ch)
% % plx_ad_v(filename, channel): Read a/d data from a .plx file
% %
% % [adfreq, n, ts, fn, ad] = plx_ad_v(filename, ch)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 0-based channel number
% %
% %           a/d data come in fragments. Each fragment has a timestamp
% %           and a number of a/d data points. The timestamp corresponds to
% %           the time of recording of the first a/d value in this fragment.
% %           All the data values stored in the vector ad.
% %
% % OUTPUT:
% %   adfreq - digitization frequency for this channel
% %   n - total number of data points
% %   ts - array of fragment timestamps (one timestamp per fragment, in seconds)
% %   fn - number of data points in each fragment
% %   ad - array of a/d values converted to mV
%
% [adfreq, n, ts, fn, ad] = mexPlex(17,filename, ch);


%%
% function [adfreq, n, ad] = local_plx_ad_span_v(filename, ch, startCount,endCount)
% % plx_ad_span_v(filename, channel): Read a span of a/d data from a .plx file
% %
% % [adfreq, n, ad] = plx_ad_span_v(filename, ch,startCount,endCount)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   startCount - index of first sample to fetch
% %   endCount - index of last sample to fetch
% %   channel - 0 - based channel number
% %
% % OUTPUT:
% %   adfreq - digitization frequency for this channel
% %   n - total number of data points
% %   ad - array of a/d values converted to mV
%
% [adfreq, n, ad] = mexPlex(18,filename, ch, startCount, endCount);


%%
% function [n, npw, ts, wave] = local_plx_waves_v(filename, ch, u)
% % plx_waves_v(filename, channel, unit): Read waveform data from a .plx file
% %
% % [n, npw, ts, wave] = plx_waves_v(filename, channel, unit)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 1-based channel number
% %   unit  - unit number (0- unsorted, 1-4 units a-d)
% % OUTPUT:
% %   n - number of waveforms
% %   npw - number of points in each waveform
% %   ts - array of timestamps (in seconds)
% %   wave - array of waveforms [npw, n] converted to mV
%
% [n, npw, ts, wave] = mexPlex(19,filename, ch, u);


%%
% function [nch, npoints, freq, d] = local_ddt_v(filename)
% % ddt_v(filename) Read data from a .ddt file returning samples in mV
% %
% % [nch, npoints, freq, d] = ddt_v(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %
% % OUTPUT:
% %   nch - number of channels
% %   npoints - number of data points for each channel
% %   freq - A/D frequency
% %   d - [nch npoints] data array (in mV)
% [nch, npoints, freq, d] = mexPlex(20,filename);


%%
% function [nCoords, nDim, nVTMode, c] = local_plx_vt_interpret(ts, sv);
% % plx_vt_interpret - interpret CinePlex video tracking data
% %
% % [nCoords, nDim, nVTMode, c] = plx_vt_interpret(ts, sv);
% %
% % Input:
% %   ts - array of timestamps (in seconds) (see plx_event_ts.m)
% %   sv - array of strobed event values (see plx_event_ts.m)
% %
% % Output:
% %   nCoords - number of produced coordinates
% %   nDim    - number of elemnts in produced coordinates
% %             nDim = 3 for CENTROID, LED_1, LED_2, LED3
% %             nDim = 4 for CENTROID_WITH_MOTION
% %             nDim = 5 for LED_12, LED_23, LED_13
% %             nDim = 7 for LED_123
% %   nVTMode - VT mode:
% %			  0 = UNKNOWN
% %			  1 = CENTROID                // 1 set of coordinates, no motion
% %			  2 = CENTROID_WITH_MOTION    // 1 set of coordinates, with motion
% %			  3 = LED_1                   // 1 set of coordinates
% %			  4 = LED_2
% %			  5 = LED_3
% %			  6 = LED_12                  // 2 sets of coordinates
% %			  7 = LED_13
% %			  8 = LED_23
% %			  9 = LED_123                 // 3 sets of coordinates
% %   c       - nCoords by nDim matrix of produced coordinates
% %             c(:, 1) - timestamp
% %             c(:, 2) - x1
% %             c(:, 3) - y1
% %             c(:, 4) - x2 or motion (if present)
% %             c(:, 5) - y2 (if present)
% %             c(:, 6) - x3 (if present)
% %             c(:, 7) - y3 (if present)
% %
% [nCoords, nDim, nVTMode, c] = mexPlex(21, '', ts, sv);


%%
function [n] = local_plx_close(filename, fid)
% % plx_close(filename): Close the .plx file
% %
% % [n] = plx_close(filename)
% %
% % INPUT:
% %   filename - if empty string, will close any open files
% % OUTPUT:
% %   n - always 0
%
% [n] = mexPlex(22,filename);

% mexplex.m can only ever have one file open, and '' will never reach this
% function, so we simply skip handling '' in hee and only close fid
disp(['Closing: ', filename]);
fclose(fid);
n = 0;
return


%%
% function [n,samplecounts] = local_plx_adchan_samplecounts(filename)
% % plx_adchan_samplecounts(filename): Read the per-channel sample counts for analog channels from a .plx file
% %
% % [n,samplecounts] = plx_adchan_samplecounts(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
%
% % OUTPUT:
% %   n - number of channels
% %   samplecounts - array of sample counts
%
% [n,samplecounts] = mexPlex(23,filename);


%%
% function [adfreq, n, ts, fn] = local_plx_ad_gap_info(filename, ch)
% % plx_ad_gap_info(filename, channel): Read a/d info from a .plx file
% %
% % [adfreq, n, ts, fn] = plx_ad_gap_info(filename, ch)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %   channel - 0-based channel number
% %
% %           a/d data come in fragments. Each fragment has a timestamp
% %           and a number of a/d data points. The timestamp corresponds to
% %           the time of recording of the first a/d value in this fragment.
% %           All the data values stored in the vector ad.
% %
% % OUTPUT:
% %   adfreq - digitization frequency for this channel
% %   n - total number of data points
% %   ts - array of fragment timestamps (one timestamp per fragment, in seconds)
% %   fn - number of data points in each fragment
%
% [adfreq, n, ts, fn] = mexPlex(24, filename, ch);


%%
% function [errCode] = local_ddt_write_v(filename, nch, npoints, freq, d)
% % ddt_write_v(filename, nch, npoints, freq, d) Write data to a .ddt file
% %
% % [errCode] = ddt_write_v(filename, nch, npoints, freq, d)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% %	nch - number of channels
% %   npoints - number of data points per channel
% %	freq - data frequency in Hz
% %	d - [nch npoints] data array (in mV)
% %
% % OUTPUT:
% %   errCode - error code: 1 for success, 0 for failure
% [errCode] = mexPlex(25, filename, nch, npoints, freq, d)


%%
% function  [n,dspchans] = local_plx_chanmap(filename)
% % plx_chanmap(filename) -- return map of raw DSP channel numbers for each channel
% %
% % [n,dspchans] = plx_chanmap(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% % OUTPUT:
% %   n - number of spike channels
% %   dspchans - 1 x n array of DSP channel numbers
% %
% % Normally, there is one channel entry in the .plx for for each raw DSP channel,
% % so the mapping is trivial dspchans[i] = i.
% % However, for certain .plx files saved in some ways from OFS (notably after
% % loading data files from other vendors), the mapping can be more complex.
% % E.g. there may be only 2 non-empty channels in a .plx file, but those channels
% % correspond to raw DSP channel numbers 7 and 34. So in this case NChans = 2,
% % and dspchans[1] = 7, dspchans[2] = 34.
% % The plx_ routines that return arrays always return arrays of size NChans. However,
% % routines that take channels numbers as arguments always expect the raw DSP
% % channel number.  So in the above example, to get the timestamps from unit 4 on
% % the second channel, use
% %   [n,ts] = plx_ts(filename, dspchans[2], 4 );
%
% [n,dspchans] = mexPlex(26,filename);


%%
% function  [n,adchans] = local_plx_ad_chanmap(filename)
% % plx_ad_chanmap(filename) -- return map of raw continuous channel numbers for each channel
% %
% % [n,adchans] = plx_ad_chanmap(filename)
% %
% % INPUT:
% %   filename - if empty string, will use File Open dialog
% % OUTPUT:
% %   n - number of continuous channels
% %   adchans - 1 x n array of continuous channel numbers
% %
% % Normally, there is one channel entry in the .plx for for each raw continuous channel,
% % so the mapping is trivial adchans[i] = i-1 (because continuous channels start at 0).
% % However, for certain .plx files saved in some ways from OFS (notably after
% % loading data files from other vendors), the mapping can be more complex.
% % E.g. there may be only 2 non-empty channels in a .plx file, but those channels
% % correspond to raw channel numbers 7 and 34. So in this case NChans = 2,
% % and adchans[1] = 7, adchans[2] = 34.
% % The plx_ routines that return arrays always return arrays of size NChans. However,
% % routines that take channels numbers as arguments always expect the raw
% % channel number.  So in the above example, to get the data from
% % the second channel, use
% %   [adfreq, n, ts, fn, ad] = plx_ad(filename, adchans[2])
%
% [n,adchans] = mexPlex(27,filename);


%%
function [sanitized_names] = sanitize_plx_names(name_array)
% there seems to be gunk in some event names from plexon .plx files, only
% report anything up to the first zero...
% also shrink array size to longest entry

[n_rows, n_cols] = size(name_array);
% create a zero filled array of the right size...
tmp_names = zeros([n_rows n_cols]);
tmp_names = char(tmp_names);
out_cols = 0;

for i_row = 1 : n_rows
	cur_name = strtok(name_array(i_row, :), char(0));
	[tmp_row, tmp_col] = size(cur_name);
	out_cols = max([out_cols size(cur_name, 2)]);
	tmp_names(i_row, 1:tmp_col) = cur_name;
end

sanitized_names = zeros([n_rows out_cols]);
sanitized_names = char(sanitized_names);

for i_row = 1 : n_rows
	sanitized_names(i_row, 1:out_cols) = tmp_names(i_row, 1:out_cols);
end

return


%%
function [PL_FileHeader] = plx_read_PL_FileHeader(fid);
% parse the PL_FileHeader from Plexon .plx files
% this way only one place has to be edited
PL_FileHeader.position_before = ftell(fid);

PL_FileHeader.MagicNumber = fread(fid, 1, 'uint32=>uint32');	%// = 0x58454c50;
PL_FileHeader.Version = fread(fid, 1, 'int32=>int32');		%// Version of the data format; determines which data items are valid
if (PL_FileHeader.Version < 105),
	% this should not happen, as we only have 'new' plexon systems, but
	% lack the information about the plexon header structure for older
	% formats
	disp('Plexon data file version is smaller than 105, too old for me to handle properly');
	return
end
PL_FileHeader.Comment = fread(fid, [1, 128], 'uint8=>char');				%// User-supplied comment
PL_FileHeader.ADFrequency = fread(fid, 1, 'int32=>int32');				%// Timestamp frequency in hertz
%disp(['Fileposition before reading NumXXXXChannels: ', num2str(ftell(fid))]);
PL_FileHeader.NumDSPChannels = fread(fid, 1, 'int32=>int32');			%// Number of DSP channel headers in the file
PL_FileHeader.NumEventChannels = fread(fid, 1, 'int32=>int32');			%// Number of Event channel headers in the file
PL_FileHeader.NumSlowChannels = fread(fid, 1, 'int32=>int32');			%// Number of A/D channel headers in the file
PL_FileHeader.NumPointsWave = fread(fid, 1, 'int32=>int32');			%// Number of data points in waveform
PL_FileHeader.NumPointsPreThr = fread(fid, 1, 'int32=>int32');			%// Number of data points before crossing the threshold
PL_FileHeader.Year = fread(fid, 1, 'int32=>int32');						%// Time/date when the data was acquired
PL_FileHeader.Month = fread(fid, 1, 'int32=>int32');					%// Time/date when the data was acquired
PL_FileHeader.Day = fread(fid, 1, 'int32=>int32');						%// Time/date when the data was acquired
PL_FileHeader.Hour = fread(fid, 1, 'int32=>int32');						%// Time/date when the data was acquired
PL_FileHeader.Minute = fread(fid, 1, 'int32=>int32');					%// Time/date when the data was acquired
PL_FileHeader.Second = fread(fid, 1, 'int32=>int32');					%// Time/date when the data was acquired
PL_FileHeader.FastRead = fread(fid, 1, 'int32=>int32');					%// reserved
PL_FileHeader.WaveformFreq = fread(fid, 1, 'int32=>int32');				%// waveform sampling rate; ADFrequency above is timestamp freq
PL_FileHeader.LastTimestamp = fread(fid, 1, 'double=>double');			%// duration of the experimental session, in ticks
% // The following 6 items are only valid if Version >= 103
PL_FileHeader.Trodalness = fread(fid, 1, 'uint8=>uint8');				%// 1 for single, 2 for stereotrode, 4 for tetrode
PL_FileHeader.DataTrodalness = fread(fid, 1, 'uint8=>uint8');			%// trodalness of the data representation
PL_FileHeader.BitsPerSpikeSample = fread(fid, 1, 'uint8=>uint8');		%// ADC resolution for spike waveforms in bits (usually 12)
PL_FileHeader.BitsPerSlowSample = fread(fid, 1, 'uint8=>uint8');		%// ADC resolution for slow-channel data in bits (usually 12)
PL_FileHeader.SpikeMaxMagnitudeMV = fread(fid, 1, 'uint16=>uint16');	%// the zero-to-peak voltage in mV for  spike waveform adc values (usually 3000)
PL_FileHeader.SlowMaxMagnitudeMV = fread(fid, 1, 'uint16=>uint16');  	%// the zero-to-peak voltage in mV for slow-channel waveform adc values (usually 5000)
% // Only valid if Version >= 105
PL_FileHeader.SpikePreAmpGain = fread(fid, 1, 'uint16=>uint16');		%// usually either 1000 or 500
% // Only valid if Version >= 106
PL_FileHeader.AcquiringSoftware = fread(fid, [1, 18], 'uint8=>char');			%// name and version of the software that originally created/acquired this data file
PL_FileHeader.ProcessingSoftware = fread(fid, [1, 18], 'uint8=>char');	%// name and version of the software that last processed/saved this data file
PL_FileHeader.Padding = fread(fid, (10), 'uint8=>uint8');					%// so that this part of the header is 256 bytes
% // Counters for the number of timestamps and waveforms in each channel and unit.
% // Note that these only record the counts for the first 4 units in each channel.
% // channel numbers are 1-based - array entry at [0] is unused
%     int     TSCounts[130][5];				%// number of timestamps[channel][unit]
%     int     WFCounts[130][5];				%// number of waveforms[channel][unit]
PL_FileHeader.TSCounts = fread(fid, [5, 130], 'int32=>int32');				%// number of timestamps[channel][unit]
PL_FileHeader.WFCounts = fread(fid, [5, 130], 'int32=>int32');				%// number of waveforms[channel][unit]
% // Starting at index 300, this array also records the number of samples for the
% // continuous channels.  Note that since EVCounts has only 512 entries, continuous
% // channels above channel 211 do not have sample counts.
PL_FileHeader.EVCounts = fread(fid, [1, 512], 'int32=>int32');				%// number of timestamps[event_number]
PL_FileHeader.position_after = ftell(fid);
return
% // file header (is followed by the channel descriptors)
% struct  PL_FileHeader V106
% {
%     unsigned int MagicNumber;   // = 0x58454c50;
%
%     int     Version;            // Version of the data format; determines which data items are valid
%     char    Comment[128];       // User-supplied comment
%     int     ADFrequency;        // Timestamp frequency in hertz
%     int     NumDSPChannels;     // Number of DSP channel headers in the file
%     int     NumEventChannels;   // Number of Event channel headers in the file
%     int     NumSlowChannels;    // Number of A/D channel headers in the file
%     int     NumPointsWave;      // Number of data points in waveform
%     int     NumPointsPreThr;    // Number of data points before crossing the threshold
%
%     int     Year;               // Time/date when the data was acquired
%     int     Month;
%     int     Day;
%     int     Hour;
%     int     Minute;
%     int     Second;
%
%     int     FastRead;           // reserved
%     int     WaveformFreq;       // waveform sampling rate; ADFrequency above is timestamp freq
%     double  LastTimestamp;      // duration of the experimental session, in ticks
%
%     // The following 6 items are only valid if Version >= 103
%     char    Trodalness;                 // 1 for single, 2 for stereotrode, 4 for tetrode
%     char    DataTrodalness;             // trodalness of the data representation
%     char    BitsPerSpikeSample;         // ADC resolution for spike waveforms in bits (usually 12)
%     char    BitsPerSlowSample;          // ADC resolution for slow-channel data in bits (usually 12)
%     unsigned short SpikeMaxMagnitudeMV; // the zero-to-peak voltage in mV for spike waveform adc values (usually 3000)
%     unsigned short SlowMaxMagnitudeMV;  // the zero-to-peak voltage in mV for slow-channel waveform adc values (usually 5000)
%
%     // Only valid if Version >= 105
%     unsigned short SpikePreAmpGain;     // usually either 1000 or 500
%
%     // Only valid if Version >= 106
%     char    AcquiringSoftware[18];      // name and version of the software that originally created/acquired this data file
%     char    ProcessingSoftware[18];     // name and version of the software that last processed/saved this data file
%
%
%
%     char    Padding[10];        // so that this part of the header is 256 bytes
%
%
%     // Counters for the number of timestamps and waveforms in each channel and unit.
%     // Note that even though there may be more than 4 units on any channel, these arrays only record the counts for the
%     // first 4 units in each channel.
%     // Channel numbers are 1-based - array entry at [0] is unused
%     int     TSCounts[130][5]; // number of timestamps[channel][unit]
%     int     WFCounts[130][5]; // number of waveforms[channel][unit]
%
%     // Starting at index 300, this array also records the number of samples for the
%     // continuous channels.  Note that since EVCounts has only 512 entries, continuous
%     // channels above channel 211 do not have sample counts.
%     int     EVCounts[512];    // number of timestamps[event_number]
% };

% 1.1	File Header
% The file header specifies general information about the PLX file including the time/date the file was created,
% global sampling parameters, the number of spike, event, and continuous channels, and a tally of timestamp and
% waveform counts for each channel.  The file header is defined by the PL_FileHeader structure (see header file Plexon.h):
%
% struct  PL_FileHeader
% {
%     unsigned int MagicNumber;	// = 0x58454c50;
%
%     int     Version;       	// Version of the data format; determines which data items are valid
%     char    Comment[128]; 	// User-supplied comment
%     int     ADFrequency; 	// Timestamp frequency in hertz
%     int     NumDSPChannels;	// Number of DSP channel headers in the file
%     int     NumEventChannels;	// Number of Event channel headers in the file
%     int     NumSlowChannels;	// Number of A/D channel headers in the file
%     int     NumPointsWave;	// Number of data points in waveform
%     int     NumPointsPreThr;	// Number of data points before crossing the threshold
%
%     int     Year;       	// Time/date when the data was acquired
%     int     Month;
%     int     Day;
%     int     Hour;
%     int     Minute;
%     int     Second;
%
%     int     FastRead;     	// reserved
%     int     WaveformFreq;     // waveform sampling rate; ADFrequency above i timestamp freq
%     double  LastTimestamp; 	// duration of the experimental session, in ticks
%
%     // The following 6 items are only valid if Version >= 103
%     char    Trodalness;      		// 1 for single, 2 for stereotrode, 4 for tetrode
%     char    DataTrodalness;   	// trodalness of the data representation
%     char    BitsPerSpikeSample; 	// ADC resolution for spike waveforms in bit (usually 12)
%     char    BitsPerSlowSample; 	// ADC resolution for slow-channel data in bit (usually 12)
%     unsigned short SpikeMaxMagnitudeMV;	// the zero-to-peak voltage in mV for spike waveform adc values (usually 3000)
%     unsigned short SlowMaxMagnitudeMV;  	// the zero-to-peak voltage in mV for  slow-channel waveform adc values  (usually 5000)
%     // Only valid if Version >= 105
%     unsigned short SpikePreAmpGain;       // usually either 1000 or 500
%
%     char    Padding[46];      // so that this part of the header is 256 bytes
%
%
%     // Counters for the number of timestamps and waveforms in each channel and unit.
%     // Note that these only record the counts for the first 4 units in each channel.
%     // channel numbers are 1-based - array entry at [0] is unused
%     int     TSCounts[130][5]; // number of timestamps[channel][unit]
%     int     WFCounts[130][5]; // number of waveforms[channel][unit]
%
%     // Starting at index 300, this array also records the number of samples for the
%     // continuous channels.  Note that since EVCounts has only 512 entries, continuous
%     // channels above channel 211 do not have sample counts.
%     int     EVCounts[512];    // number of timestamps[event_number]
% };


%%
function [PL_ChanHeader] = plx_read_PL_ChanHeader(fid)
% parse PL_ChanHeader from plexon .plx files
% the documention seems to be for version 106
PL_ChanHeader.position_before = ftell(fid);

PL_ChanHeader.Name = fread(fid, [1, 32], 'uint8=>char');		%// Name given to the DSP channel
PL_ChanHeader.SIGName = fread(fid, [1, 32], 'uint8=>char');		%// Name given to the corresponding SIG channel
PL_ChanHeader.Channel = fread(fid, 1, 'int32=>int32');			%// DSP channel number, 1-based
PL_ChanHeader.WFRate = fread(fid, 1, 'int32=>int32');			%// When MAP is doing waveform rate limiting, this is limit w/f per sec divided by 10
PL_ChanHeader.SIG = fread(fid, 1, 'int32=>int32');				%// SIG channel associated with this DSP channel 1 - based
PL_ChanHeader.Ref = fread(fid, 1, 'int32=>int32');				%// SIG channel used as a Reference signal, 1- based
PL_ChanHeader.Gain = fread(fid, 1, 'int32=>int32');				%// actual gain divided by SpikePreAmpGain. For pre version 105, actual gain divided by 1000.
PL_ChanHeader.Filter = fread(fid, 1, 'int32=>int32');			%// 0 or 1
PL_ChanHeader.Threshold = fread(fid, 1, 'int32=>int32');		%// Threshold for spike detection in a/d values
PL_ChanHeader.Method = fread(fid, 1, 'int32=>int32');			%// Method used for sorting units, 1 - boxes, 2 - templates
PL_ChanHeader.NUnits = fread(fid, 1, 'int32=>int32');			%// number of sorted units
PL_ChanHeader.Template = fread(fid, [64, 5], 'int16=>int16');	%// Templates used for template sorting, in a/d values
PL_ChanHeader.Fit = fread(fid, [1, 5], 'int32=>int32');			%// Template fit
PL_ChanHeader.SortWidth = fread(fid, 1, 'int32=>int32');		%// how many points to use in template sorting (template only)
PL_ChanHeader.Boxes = fread(fid, [10, 4], 'int16=>int16');		%// the boxes used in boxes sorting should be [5][2][4]
PL_ChanHeader.SortBeg = fread(fid, 1, 'int32=>int32');			%// beginning of the sorting window to use in template sorting (width defined by SortWidth)
PL_ChanHeader.Comment = fread(fid, [1, 128], 'uint8=>char');	%// Version >=105
PL_ChanHeader.SrcId = fread(fid, 1, 'uint8=>uint8');			%// Version >=106, Plexus Source ID for this channel
PL_ChanHeader.reserved = fread(fid, 1, 'uint8=>uint8');			%// Version >=106
PL_ChanHeader.ChanId = fread(fid, 1, 'uint16=>uint16');			%// Version >=106, Plexus Channel ID within the Source for this channel
PL_ChanHeader.Padding = fread(fid, 10, 'int32=>int32');

PL_ChanHeader.position_after = ftell(fid);
return
% struct PL_ChanHeader V106
% {
%     char    Name[32];       // Name given to the DSP channel
%     char    SIGName[32];    // Name given to the corresponding SIG channel
%     int     Channel;        // DSP channel number, 1-based
%     int     WFRate;         // When MAP is doing waveform rate limiting, this is limit w/f per sec divided by 10
%     int     SIG;            // SIG channel associated with this DSP channel 1 - based
%     int     Ref;            // SIG channel used as a Reference signal, 1- based
%     int     Gain;           // actual gain divided by SpikePreAmpGain. For pre version 105, actual gain divided by 1000.
%     int     Filter;         // 0 or 1
%     int     Threshold;      // Threshold for spike detection in a/d values
%     int     Method;         // Method used for sorting units, 1 - boxes, 2 - templates
%     int     NUnits;         // number of sorted units
%     short   Template[5][64];// Templates used for template sorting, in a/d values
%     int     Fit[5];         // Template fit
%     int     SortWidth;      // how many points to use in template sorting (template only)
%     short   Boxes[5][2][4]; // the boxes used in boxes sorting
%     int     SortBeg;        // beginning of the sorting window to use in template sorting (width defined by SortWidth)
%     char    Comment[128];   // Version >=105
%     unsigned char SrcId;    // Version >=106, Plexus Source ID for this channel
%     unsigned char reserved; // Version >=106
%     unsigned short ChanId;  // Version >=106, Plexus Channel ID within the Source for this channel
%     int     Padding[10];
% };

% 1.2	Spike Channel Header
% The spike channel header provides general information about the spike channel including its name,
% channel number, gains/filters, and sorting methods.  There is one spike channel header for each
% spike channel as specified by the NumDSPChannels field of the PL_FileHeader.  The spike channel
% header is defined by the PL_ChanHeader structure (see header file Plexon.h):
%
% struct PL_ChanHeader
% {
%     char    Name[32];       	// Name given to the DSP channel
%     char    SIGName[32];    	// Name given to the corresponding SIG channel
%     int     Channel;        	// DSP channel number, 1-based
%     int     WFRate;         	// When MAP is doing waveform rate limiting, this is  limit w/f per sec divided by 10
%     int     SIG;            	// SIG channel associated with this DSP channel 1 - based
%     int     Ref;            	// SIG channel used as a Reference signal, 1- based
%     int     Gain;           	// actual gain divided by SpikePreAmpGain. For pre version 105, actual gain divided by 1000.
%     int     Filter;         	// 0 or 1
%     int     Threshold;      	// Threshold for spike detection in a/d values;
%     int     Method;         	// Method used for sorting units, 1 - boxes, 2 - templates
%     int     NUnits;         	// number of sorted units
%     short   Template[5][64];	// Templates used for template sorting, in a/d values
%     int     Fit[5];         	// Template fit
%     int     SortWidth;      	// how many points to use in template sorting (template only)
%     short   Boxes[5][2][4]; 	// the boxes used in boxes sorting
%     int     SortBeg;        	// beginning of the sorting window to use in template sorting (width defined by SortWidth)
%     char    Comment[128];
%     int     Padding[11];
% };


%%
function [PL_EventHeader] = plx_read_PL_EventHeader(fid)
% parse PL_EventHeader from plexon .plx files
% the documention seems to be for version 106
PL_EventHeader.position_before = ftell(fid);

PL_EventHeader.Name = fread(fid, [1, 32], 'uint8=>char');		%// name given to this event
PL_EventHeader.Channel = fread(fid, 1, 'int32=>int32');			%// event number, 1-based
PL_EventHeader.Comment = fread(fid, [1, 128], 'uint8=>char');	%// Version >=105
PL_EventHeader.SrcId = fread(fid, 1, 'uint8=>uint8');			%// Version >=106, Plexus Source ID for this channel
PL_EventHeader.reserved = fread(fid, 1, 'uint8=>uint8');		%// Version >=106
PL_EventHeader.ChanId = fread(fid, 1, 'uint16=>uint16');		%// Version >=106, Plexus Channel ID within the Source for this channel
PL_EventHeader.Padding = fread(fid, 32, 'int32=>int32');

PL_EventHeader.position_after = ftell(fid);
return
% struct PL_EventHeader V106
% {
%     char    Name[32];       // name given to this event
%     int     Channel;        // event number, 1-based
%     char    Comment[128];   // Version >=105
%     unsigned char SrcId;    // Version >=106, Plexus Source ID for this channel
%     unsigned char reserved; // Version >=106
%     unsigned short ChanId;  // Version >=106, Plexus Channel ID within the Source for this channel
%     int     Padding[32];
% };
%
% 1.3	Event Channel Header
% The event channel header provides information about an event channel including
% its name and channel number.  There is one event channel header for each event
% channel as specified by the NumEventChannels field of the PL_FileHeader.  The
% event channel header is defined by the PL_EventHeader (see header file Plexon.h):
%
% struct PL_EventHeader
% {
%     char    Name[32];       // name given to this event
%     int     Channel;        // event number, 1-based
%     char    Comment[128];
%     int     Padding[33];
% };


%%
function [PL_SlowChannelHeader] = plx_read_PL_SlowChannelHeader(fid)
% parse PL_SlowChannelHeader from plexon .plx files
% the documention seems to be for version 105
PL_SlowChannelHeader.position_before = ftell(fid);

PL_SlowChannelHeader.Name = fread(fid, [1, 32], 'uint8=>char');		%// name given to this channel
PL_SlowChannelHeader.Channel = fread(fid, 1, 'int32=>int32');		%// channel number, 0-based
PL_SlowChannelHeader.ADFreq = fread(fid, 1, 'int32=>int32');		%// digitization frequency
PL_SlowChannelHeader.Gain = fread(fid, 1, 'int32=>int32');			%// gain at the adc card
PL_SlowChannelHeader.Enabled = fread(fid, 1, 'int32=>int32');		%// whether this channel is enabled for taking data, 0 or 1
PL_SlowChannelHeader.PreAmpGain = fread(fid, 1, 'int32=>int32');	%// gain at the preamp

%// As of Version 104, this indicates the spike channel (PL_ChanHeader.Channel) of
%// a spike channel corresponding to this continuous data channel.
%// <=0 means no associated spike channel.
PL_SlowChannelHeader.SpikeChannel = fread(fid, 1, 'int32=>int32');

PL_SlowChannelHeader.Comment = fread(fid, [1, 128], 'uint8=>char');	%// Version >=105
PL_SlowChannelHeader.SrcId = fread(fid, 1, 'uint8=>uint8');			%// Version >=106, Plexus Source ID for this channel
PL_SlowChannelHeader.reserved = fread(fid, 1, 'uint8=>uint8');		%// Version >=106
PL_SlowChannelHeader.ChanId = fread(fid, 1, 'uint16=>uint16');		%// Version >=106, Plexus Channel ID within the Source for this channel
PL_SlowChannelHeader.Padding = fread(fid, 27, 'int32=>int32');

PL_SlowChannelHeader.position_after = ftell(fid);
return
% struct PL_SlowChannelHeader V106
% {
%     char    Name[32];       // name given to this channel
%     int     Channel;        // channel number, 0-based
%     int     ADFreq;         // digitization frequency
%     int     Gain;           // gain at the adc card
%     int     Enabled;        // whether this channel is enabled for taking data, 0 or 1
%     int     PreAmpGain;     // gain at the preamp
%
%     // As of Version 104, this indicates the spike channel (PL_ChanHeader.Channel) of
%     // a spike channel corresponding to this continuous data channel.
%     // <=0 means no associated spike channel.
%     int     SpikeChannel;
%
%     char    Comment[128];   // Version >=105
%     unsigned char SrcId;    // Version >=106, Plexus Source ID for this channel
%     unsigned char reserved; // Version >=106
%     unsigned short ChanId;  // Version >=106, Plexus Channel ID within the Source for this channel
%     int     Padding[27];
% };
%
% 1.4	Continuous Channel Header
% The Continuous A/D channel header provides information about the continuous
% A/D channel including its name, channel number, sampling frequency, and gains.
% The continuous channel header is defined by the PL_SlowChannelHeader
% (see header file Plexon.h):
%
% struct PL_SlowChannelHeader
% {
%     char    Name[32];       // name given to this channel
%     int     Channel;        // channel number, 0-based
%     int     ADFreq;         // digitization frequency
%     int     Gain;           // gain at the adc card
%     int     Enabled;        // whether this channel is enabled for taking data, 0 or 1
%     int     PreAmpGain;     // gain at the preamp
%
%     // As of Version 104, this indicates the spike channel (PL_ChanHeader.Channel) of
%     // a spike channel corresponding to this continuous data channel.
%     // <=0 means no associated spike channel.
%     int     SpikeChannel;
%
%     char    Comment[128];
%     int     Padding[28];
% };


%%
function [PL_DataBlockHeader] = plx_read_PL_DataBlockHeader(fid)

% // The header for the data record used in the datafile (*.plx)
% // This is followed by NumberOfWaveforms*NumberOfWordsInWaveform
% // short integers that represent the waveform(s)
PL_DataBlockHeader.position_before = ftell(fid);

PL_DataBlockHeader.Type = fread(fid, 1, 'int16=>int16');						%// Data type; 1=spike, 4=Event, 5=continuous
PL_DataBlockHeader.UpperByteOf5ByteTimestamp = fread(fid, 1, 'uint16=>uint16');	%// Upper 8 bits of the 40 bit timestamp
PL_DataBlockHeader.TimeStamp = fread(fid, 1, 'uint32=>uint32');					%// Lower 32 bits of the 40 bit timestamp
PL_DataBlockHeader.Channel = fread(fid, 1, 'int16=>int16');						%// Channel number
PL_DataBlockHeader.Unit = fread(fid, 1, 'int16=>int16');						%// Sorted unit number; 0=unsorted
PL_DataBlockHeader.NumberOfWaveforms = fread(fid, 1, 'int16=>int16');			%// Number of waveforms in the data to follow, usually 0 or 1
PL_DataBlockHeader.NumberOfWordsInWaveform = fread(fid, 1, 'int16=>int16');		%// Number of samples per waveform in the data to follow
% }; // 16 bytes

PL_DataBlockHeader.position_after = ftell(fid);
return
% // The header for the data record used in the datafile (*.plx)
% // This is followed by NumberOfWaveforms*NumberOfWordsInWaveform
% // short integers that represent the waveform(s)
%
% struct PL_DataBlockHeader V 106
% {
%     short   Type;                       // Data type; 1=spike, 4=Event, 5=continuous
%     unsigned short   UpperByteOf5ByteTimestamp; // Upper 8 bits of the 40 bit timestamp
%     unsigned long    TimeStamp;                 // Lower 32 bits of the 40 bit timestamp
%     short   Channel;                    // Channel number
%     short   Unit;                       // Sorted unit number; 0=unsorted
%     short   NumberOfWaveforms;          // Number of waveforms in the data to folow, usually 0 or 1
%     short   NumberOfWordsInWaveform;    // Number of samples per waveform in the data to follow
% }; // 16 bytes

% 1.5	Data Block Header V 105
% Each data block begins with a data block header and may be followed with waveform
% data.  The data block header provides information about the data block including
% its type, timestamp, channel/unit number, and the number of samples in the
% waveform data if present.  The data block header is defined by the PL_DataBlockHeader
% structure (see header file Plexon.h):
%
% // The header for the data record used in the datafile (*.plx)
% // This is followed by NumberOfWaveforms*NumberOfWordsInWaveform
% // short integers that represent the waveform(s)
%
% struct PL_DataBlockHeader
% {
%     short   Type;								// Data type; 1=spike, 4=Event, 5=continuous
%     unsigned short   UpperByteOf5ByteTimestamp; // Upper 8 bits of the 40 bit timestamp
%     unsigned long    TimeStamp;                 // Lower 32 bits of the 40 bit timestamp
%     short   Channel;							// Channel number
%     short   Unit;								// Sorted unit number; 0=unsorted
%     short   NumberOfWaveforms;					// Number of waveforms in the data to
%    	// follow, usually 0 or 1
%     short   NumberOfWordsInWaveform;			// Number of samples per waveform in the
% // data to follow
% }; // 16 bytes
%
% Every data block has a 5-byte timestamp that represent elapsed time in ticks
% (sampling periods).  The ADFrequency field in the PL_FileHeader structure
% determines the number of ticks per second.  For example, if the ADFrequency is
% 40,000, then a timestamp representing 1 second would be equal to 40000.
% 5-byte timestamps require special handling in C/C++.  The lower 4-bytes of
% the time stamp (TimeStamp) and the upper byte of the time stamp
% (UpperByteOf5ByteTimeStamp) can be packed into a 64-bit LONGLONG data type as below:
%
% LONGLONG ts = ((static_cast<LONGLONG>(dataBlock.UpperByteOf5ByteTimestamp)<<32)
% + static_cast<LONGLONG>(dataBlock.TimeStamp)) ;
%
% The following C/C++ code will convert the  LONGLONG timestamp from ticks to seconds:
%
% double seconds = (double) ts / (double) fileHeader.ADFrequency ;
%
% The Type field in the data block header determines whether the data block
% is a spike data block  (PL_SingleWFType), event data block (PL_ExtEventType),
% or a continuous A/D data block (PL_ADDataType).


%%
function [spike, event, ad, fposmap] = plx_read_data(fid, PLX_header, opts)
% parse the data portion of the plex files opened as fid
% this expects that the file was fully written and all expected data can be
% found. We try to perform all processing that is reasonable as we single
% step over all datablocks anyway, so we might avoid later cycling over and
% arrays of structs
% TODO:
%	detect fragments/segments (needed to structure AD data)
%	make output configureable (spike waveforms are really large, only export if needed)
%	what about multitrodes, will require changes in spike_wf output
%		potentially return one spike_wf array per channel
%	check the dimesion order of the arrays with matlabs colums first
%		representation
%
% DONE:
%	show progress indicator (use ftell and filesize?)
%	build file position table for all three data types... (include size
%	with payload)
%	test spike_wf
%	test ad_wf
%	test fposmap

% PLX_header.PL_FileHeader
% PLX_header.PL_ChanHeader
% PLX_header.PL_EventHeader
% PLX_header.PL_SlowChannelHeader


% calculate file size (this takes less than a second...)
plx_parse_time = tic;
% find the first_PL_DataBlockHeader
first_PL_DataBlockHeader_fpos = PLX_header.PL_SlowChannelHeader(end).position_after;
fseek(fid, 0, 'eof');
fsize = ftell(fid);
fseek(fid, first_PL_DataBlockHeader_fpos, 'bof');

% put the timestamp in the smalles type possible, we might have to return
% doubles in the end, but this keeps the persistent representation smaller
if (PLX_header.PL_FileHeader.LastTimestamp < (2^32 - 1)),
	ts_int = 1;
	ts_type_class = 'uint32';
else
	ts_int = 0;
	ts_type_class = 'double';
end

% preallocate storage (if possible)
% spikes
if (opts.spike_event_ad),
	if (opts.spike_wf),
	n_total_spike_wf = sum(sum(PLX_header.PL_FileHeader.WFCounts));
	spike.wf_haeder = {'waveform_ad_units'};
	spike_wf = zeros([n_total_spike_wf PLX_header.PL_FileHeader.NumPointsWave], 'int16');	% fix for stereo- and tetrodes
else
	spike.wf_haeder = {};
	spike_wf = int16([]);
end
n_total_spike_ts = sum(sum(PLX_header.PL_FileHeader.TSCounts));	% should be the same as n_total_spike_wf, if all waveforms are saved
spike.ts_header = {'timestamp'};
spike_ts = zeros([n_total_spike_ts 1], ts_type_class);
spike.short_header =  {'dsp_channel', 'unit', 'n_waveforms', 'n_words'};
spike_short = zeros([n_total_spike_ts 4], 'int16');

% events
n_total_events = sum(PLX_header.PL_FileHeader.EVCounts(1:300));
event.ts_header = {'timestamp'};
event_ts = zeros([n_total_events 1], ts_type_class);
event.short_header = {'event_channel', 'strobed_value'};
event_short = zeros([n_total_events 2], 'int16');

% analog data
% at 1000 Hz blocks have either 16 or 15 entries, assume the minimum
n_estimated_adblocks = floor(sum(PLX_header.PL_FileHeader.EVCounts(301:end)) / 15);	% we can only guess how many ad_blocks were written

ad.ts_header = {'timestamp'};
ad_ts = zeros([n_estimated_adblocks 1], ts_type_class);
ad.short_header = {'ad_chanel', 'n_words', 'fragment'};
ad_short = zeros([n_estimated_adblocks 3], 'int16');
if (opts.ad_wf),
	n_ad_samples = sum(PLX_header.PL_FileHeader.EVCounts(301:end));
	ad.wf_header = {'waveform_ad_units', 'channel', 'fragment'};
	ad_wf = zeros([n_ad_samples 3], 'int16');
	ad.wf_ad_block_header = {'ad_block_num'};
	ad_wf_ad_block = zeros([n_ad_samples 1], ts_type_class);
	ticks_per_ad_sample = ceil(double(PLX_header.PL_FileHeader.ADFrequency) / double(PLX_header.PL_SlowChannelHeader(1).ADFreq));
	ad_fragment_slack_in_ticks = 3 * ticks_per_ad_sample;
	ad.fragment_ts_header = {'timestamp'};
	ad_fragment_ts = zeros([100 1], ts_type_class);	% we assume less than 100 fragments
else
	ad.wf_header = {};
	ad_wf = int16([]);
	ad.fragment_ts_header = {};
	ad_fragment_ts = [];
end
else
	spike.wf_haeder = {};
	spike_wf = int16([]);
	spike.ts_header = {};
	spike_ts = [];
	spike.short_header =  {};
	spike_short = int16([]);
	event.ts_header = {};
	event_ts = [];
	event.short_header = {};
	event_short = int16([]);
	ad.ts_header = {};
	ad_ts = [];
	ad.short_header = {};
	ad_short = int16([]);
	ad.wf_header = {};
	ad_wf = int16([]);
	ad.wf_ad_block_header = {};
	ad_wf_ad_block = uint32([]);
end

% file position map
n_estimated_data_block_headers = n_total_spike_ts + n_total_events + n_estimated_adblocks;
if (opts.fposmap),
	fposmap.ts_header = {'timestamp', 'fpos_before'};	% due to the fpos we need > 32bit, so double it is
	fposmap_ts = zeros([n_estimated_data_block_headers 1], 'double');
	fposmap.short_header = {'data_header_and_payload_size_bytes', 'type', 'channel', 'unit'};
	fposmap_short = zeros([n_estimated_data_block_headers 1], 'int16');
else
	fposmap.ts_header = {};
	fposmap.short_header = {};
	fposmap_ts = double([]);
	fposmap_short = int16([]);
end

% init some stuff
n_data_blocks = 0;
n_spike_blocks = 0;
n_event_blocks = 0;
n_ad_blocks = 0;
ad_wf_start = 0;
n_ad_fragments = int16(0);

while ~feof(fid)
	n_data_blocks = n_data_blocks + 1;

	if (mod(n_data_blocks, (floor(n_estimated_data_block_headers / 100))) == 0),
		disp(sprintf('n_data_blocks: %d n_spike_blocks: %d n_event_blocks: %d n_ad_blocks: %d (%.1f%%)', n_data_blocks, n_spike_blocks, n_event_blocks, n_ad_blocks, 100*ftell(fid)/fsize));
	end

	PL_DataBlockHeader = plx_read_PL_DataBlockHeader(fid);
	if feof(fid),
		disp('Encountered EOF, somewhat unexpectedly...');
		break;
	end
	
	if (PL_DataBlockHeader.NumberOfWaveforms > 0),	% read the payload, if any
		%TODO check Type and create buffer of appropriate size for
		%spike_wfs
		n_samples_in_data = double(PL_DataBlockHeader.NumberOfWordsInWaveform * PL_DataBlockHeader.NumberOfWaveforms);
		payload = fread(fid, [1, n_samples_in_data], 'int16=>int16');
	end
	fpos_after = ftell(fid);
	data_block_n_bytes = fpos_after - PL_DataBlockHeader.position_before;

	% a 64 bit double will store up to 52 integer bits so it is sufficient
	% for a 40 bit timestamp, 40 bit @ 40kHz seems to last for 318 days, so
	% even at 80kHz 32 bits would last for 14.9 hours, so what shall we do?
	% TODO: check whether we get anything but zeros in the upper byte and
	% only return 32bit Timestamp in that case... since we know the last
	% timestamp in the plx file let's do it...
	if (ts_int)
		timestamp = PL_DataBlockHeader.TimeStamp;
	else
		timestamp = double(PL_DataBlockHeader.UpperByteOf5ByteTimestamp) * (2^32) + PL_DataBlockHeader.TimeStamp;
	end

	if (opts.fposmap),
		% 'timestamp', 'fpos_before'
		fposmap_ts(n_data_blocks, 1) = double(timestamp);
		fposmap_ts(n_data_blocks, 2) = PL_DataBlockHeader.position_before;
		% datasize_bytes', 'type', 'channel', 'unit'
		fposmap_short(n_data_blocks, 1) = data_block_n_bytes;
		fposmap_short(n_data_blocks, 2) = PL_DataBlockHeader.Type;
		fposmap_short(n_data_blocks, 3) = PL_DataBlockHeader.Channel;
		fposmap_short(n_data_blocks, 4) = PL_DataBlockHeader.Unit;
	end
	
	if (opts.spike_event_ad),
		switch PL_DataBlockHeader.Type	%// Data type; 1=spike, 4=Event, 5=continuous
			case 1 % PL_SingleWFType
				n_spike_blocks = n_spike_blocks + 1;
				% 			if (n_spike_blocks == 1),
				% 				PL_SingleWFType = PL_DataBlockHeader;
				% 			else
				% 				PL_SingleWFType(n_spike_blocks) = PL_DataBlockHeader;
				% 			end
				% 'timestamp', 'dsp_channel', 'unit', 'n_waveforms', 'n_words'
				spike_ts(n_spike_blocks, 1) = timestamp;
				spike_short(n_spike_blocks, 1) = double(PL_DataBlockHeader.Channel);
				spike_short(n_spike_blocks, 2) = double(PL_DataBlockHeader.Unit);
				spike_short(n_spike_blocks, 3) = double(PL_DataBlockHeader.NumberOfWaveforms);
				spike_short(n_spike_blocks, 4) = double(PL_DataBlockHeader.NumberOfWordsInWaveform);
				if (opts.spike_wf),
					% 'waveform_ad_units'
					if (PL_DataBlockHeader.NumberOfWaveforms > 1),
						disp('Oh ha, this is no monotrode, please fix me...');
						keyboard
					end
					spike_wf(n_spike_blocks, :) = payload;	% we need 2D array, 3D for stereo/tetrodes
				end

			case 4 % PL_ExtEventType
				n_event_blocks = n_event_blocks + 1;
				% 			if (n_event_blocks == 1),
				% 				PL_SingleWFType = PL_DataBlockHeader;
				% 			else
				% 				PL_ExtEventType(n_event_blocks) = PL_DataBlockHeader;
				% 			end
				% 'timestamp', 'event_channel', 'strobed_value' (only if evch == 257)
				event_ts(n_event_blocks, 1) = timestamp;
				event_short(n_event_blocks, 1) = double(PL_DataBlockHeader.Channel);
				event_short(n_event_blocks, 2) = double(PL_DataBlockHeader.Unit);

			case 5	% PL_ADDataType
				n_ad_blocks = n_ad_blocks + 1;
				% 			if (n_ad_blocks == 1),
				% 				PL_ADDataType = PL_DataBlockHeader;
				% 			else
				% 				PL_ADDataType(n_ad_blocks) = PL_DataBlockHeader;
				% 			end
				% 'timestamp', 'ad_chanel', 'n_words'
				
				% get the ad fragment number				
				if (n_ad_blocks == 1),
					n_ad_fragment = 1;
					ad_fragment_ts(n_ad_fragment) =  timestamp;
				else
					% all ad channels run on sync time, so for each
					% ad_block ts we find n_slowchannels ad_blockheaders
					% with the exact same timestamp
					last_block = n_ad_blocks - 1;
					if (timestamp ~= ad_ts(last_block, 1)),
						expected_ts = cast(ad_ts(last_block, 1) + double(ticks_per_ad_sample * ad_short(last_block, 2)), ts_type_class);

						if (abs(timestamp - expected_ts) > ad_fragment_slack_in_ticks),
							n_ad_fragment = n_ad_fragment + 1;
							ad_fragment_ts(n_ad_fragment, 1) =  timestamp;
						end
					end
				end
				
				ad_ts(n_ad_blocks, 1) = timestamp;
				ad_short(n_ad_blocks, 1) = PL_DataBlockHeader.Channel;
				ad_short(n_ad_blocks, 2) = PL_DataBlockHeader.NumberOfWordsInWaveform;
				ad_short(n_ad_blocks, 3) = n_ad_fragment;

				if (opts.ad_wf),
					ad_wf_start = ad_wf_start + 1;
					ad_wf_stop = ad_wf_start + double(PL_DataBlockHeader.NumberOfWordsInWaveform) - 1;
					% 'waveform_ad_units'
					ad_wf(ad_wf_start:ad_wf_stop, 1) = payload;	% we need 1D array, but we need to special case segmented recording files that contain gaps even in the continuous data
					ad_wf(ad_wf_start:ad_wf_stop, 2) = PL_DataBlockHeader.Channel;
					ad_wf(ad_wf_start:ad_wf_stop, 3) = n_ad_fragment;
					ad_wf_ad_block(ad_wf_start:ad_wf_stop, 1) = n_ad_blocks;	% the block_id to find the first timestamp, type as ad_ts as int16 is way too small
					ad_wf_start = ad_wf_stop;
				end

			otherwise
				disp(['Encountered unknown PL_DataBlockHeader.Type ', num2str(PL_DataBlockHeader.Type), ', please debug me...']);
				PL_DataBlockHeader
				keyboard;
		end
	end
end

%FIXME
spike.ts = spike_ts;
spike.short = spike_short;
spike.wf = spike_wf;

event.ts = event_ts;
event.short = event_short;

ad.ts = ad_ts;
ad.short = ad_short;
ad.wf = ad_wf;	% this is correct
ad.wf_ad_block = ad_wf_ad_block;

if (opts.ad_wf),
	ad.fragment_ts = ad_fragment_ts;
	% we over-estimate n_ad_fragment
	zero_entries = find(ad_fragment_ts(:) == 0);
	if (ad_fragment_ts(1) == 0),
		zero_entries(1) = [];
	end
	ad.fragment_ts(zero_entries) = [];
end

if (opts.spike_event_ad),
	% we over-estimate n_ad_blocks
	zero_entries = find(ad_ts(:) == 0);
	if (ad_ts(1) == 0),
		zero_entries(1) = [];
	end
	ad.ts(zero_entries) = [];
	ad.short(zero_entries, :) = [];
end

fposmap.ts = fposmap_ts;
fposmap.short = fposmap_short;	
if (opts.fposmap),
	zero_entries = find(fposmap_ts(:, 1) == 0);
	if (fposmap_ts(1, 1) == 0),
		zero_entries(1) = [];
	end
	fposmap.ts(zero_entries, :) = [];
	fposmap.short(zero_entries, :) = [];
end

disp('Parsing the .plx file finished.');
toc (plx_parse_time);
return


