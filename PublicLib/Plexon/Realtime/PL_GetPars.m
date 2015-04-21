function p = PL_GetPars(s);  
%
% PL_GetPars - get the current Rasputin acquisition parameters
%
% p = PL_GetPars(s)
%
% Input: 
%   s - server reference (see PL_InitClient)
%
% Output:
%   p - 525 by 1 matrix, vector of parameters
%   
%	p(1) = Number of DSP channels (16 to 128)
%	p(2) = Timestamp tick (in usec) (usually 25 usec)
%	p(3) = Number of points in spike waveform
%	p(4) = Number of points before threshold
%	p(5) = Maximum number of points in spike waveform
%	p(6) = Total number of A/D channels (16 to 256)
%	p(7) = Number of enabled A/D channels
%	p(8) = Continuous A/D frequency ("slow channel" rate, e.g. 1 kHz)
%	p(9) = Server polling interval in msec 
%	p(10) = 1 if MAP DSP program is loaded 
%	p(11) = 1 if Sort Client is running
%	p(12) = (reserved)
%   p(13) = Continuous A/D frequency ("fast channel" rate, 20 kHz or 40 kHz)
%   
%	p(14)  .. p(269) = Per-channel sampling rates for enabled 
%     continuous A/D channels, e.g. 
%       pars(14) is the sampling rate for the first enabled A/D channel, 
%       pars(15) is the rate for the second enabled A/D channel, etc.  
%     note that although 256 entries are reserved for sampling rates in 
%     pars(), if there are less than 256 enabled channels, the trailing 
%     unused entries will be 0.
%
%   p(270) .. p(525) = Sort Client channels numbers for enabled
%     continuous A/D channels, e.g.
%       pars(14+256) is the channel number for the first enabled channel, 
%       pars(15+256) is the second enabled channel, etc.
%     note that although 256 entries are reserved for enabled channel 
%     numbers in pars(), if there are less than 256 enabled channels, the 
%     trailing unused entries will be 0.
%
% See test_pars.m for an example of the use of this function.
%
% Copyright (c) 2004-2007, Plexon Inc
%
p = mexPlexOnline(4, s);
