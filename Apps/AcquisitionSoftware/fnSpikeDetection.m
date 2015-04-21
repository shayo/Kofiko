%  Step 1. Read the data and resample.

strFile = 'C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2010\12-11-08_17-05-07\100_CH3.continuous';
strFileType = 'open-ephys';
[data, timestamps, ndata, fSamplingRate, aftime] =read_open_ephys_data(strFile);
afSamplesTimeDiff = diff(aftime);

figure;
plot((aftime(1:4000)-aftime(1))*1e3)

timestamps=timestamps-timestamps(1);
timestamps(1:10)*1e3
ndata(1)/fSamplingRate*1e3
1024

figure(11);
clf;
plot(timestamps(1):timestamps(1)+ndata(1));

% Resample data to be evenly sampled....
fDesiredSampledRate = 30000;
[afTime, afResampledData] = fnResampleData(data, timestamps, fSamplingRate, fDesiredSampledRate);

% resample the data

figure;
plot(timestamps)

figure;plot(data)

[t,amps,data,aux] = read_intan_data('C:\Users\shayo\Desktop\TestSessionWithJulien\Exp1_Cont_121102_111839.int');
iNumChannels = size(data,2);
%for iChannel=1:iNumChannels
[t2,amps2,data2,aux2] = read_intan_data('C:\Users\shayo\Desktop\TestSessionWithJulien\Exp2_Cont_121102_112142.int');
afSignal = data2(:,1)';
afTime=t2';

%%
% Generate a pure sine wave
fSamplingRate = 25000;
NumTaps =6 ;
% fSineWaveTestFreq = 1000;
% fPhase = 40/180*pi;
%iNumSeconds = 4;
%afTime= [0:(fSamplingRate*iNumSeconds)-1]/fSamplingRate;
%afSignal = sin([2*pi*fSineWaveTestFreq*afTime]+fPhase) ;%+ sin([2*pi*fSineWaveTestFreq2*afTime]+fPhase2);

fLow = 600;
fHigh = 3000;
afNormalizedFreq = [fLow,fHigh ]*2/fSamplingRate;
[b_butter,a_butter]=butter(NumTaps,afNormalizedFreq);
[b_ellip,a_ellip]=ellip(2,0.1,40,afNormalizedFreq);
b=b_butter;
a=a_butter;
% b=b_ellip;
% a=a_ellip;

afSignalFiltered=filtfilt(b,a,afSignal);


NFFT = 2^nextpow2(length(afSignal)); % Next power of 2 from length of y

afSignalFFt = fft(afSignal,NFFT)/length(afSignal);
afSignalFilteredFFt = fft(afSignalFiltered,NFFT)/length(afSignalFiltered);
afFreqMag = 2*abs(afSignalFFt(1:NFFT/2+1));
afPhaseRes = angle(afSignalFFt(1:NFFT/2+1))/pi*180;

afFreqMag_Filt = 2*abs(afSignalFilteredFFt(1:NFFT/2+1));
afPhaseRes_Filt = angle(afSignalFilteredFFt(1:NFFT/2+1))/pi*180;


afFFTSpace =  fSamplingRate/2*linspace(0,1,NFFT/2+1);
figure(7);clf;

h1=subplot(2,3,1);
plot(afTime,afSignal,'b');hold on;
h2=subplot(2,3,4);
plot(afTime,afSignalFiltered,'r');
linkaxes([h1,h2]);

set(gca,'xlim',[ 24.0450   24.0483],'ylim',[  -14.9067   13.1830]);


set(gca,'xlim',afTime([1,end]),'ylim',[-2 2]);
h2=subplot(3,1,2);
plot(afFFTSpace,afFreqMag,'b.') 
hold on;
plot(afFFTSpace,afFreqMag_Filt,'r');
h3=subplot(3,1,3);
plot(afFFTSpace,afPhaseRes);
hold on;
plot(afFFTSpace,afPhaseRes_Filt,'r');
set(gca,'ylim',[-180 180]);
linkaxes([ h2 h3],'x');
set(gca,'xlim',[0 2*fSineWaveTestFreq]);
%%

subplot(3,1,1);hold on;;
plot(afTime, afSignalFiltered,'r');

figure(2);
clf;
plot(afTime,afSignal);hold on;
plot(afTime,afSignalFiltered,'r');
set(gca,'xlim',[0 0.1],'ylim',[-2 2])
    %%
    
    xf_detect=filtfilt(b,a,x);

[b_ellip,a_ellip]=ellip(2,0.1,40,[400 3000]*2/fSamplingRate);

% HIGH-PASS FILTER OF THE DATA
x = data2(:,1);
xf=zeros(length(x),1);
if exist('ellip')                         %Checks for the signal processing toolbox
    [b,a]=ellip(2,0.1,40,[fmin_detect fmax_detect]*2/fSamplingRate);
    xf_detect=filtfilt(b,a,x);
else
    xf_detect = fix_filter(x);                   %Does a bandpass filtering between [300 3000] without the toolbox.
end
lx=length(xf);


stdmin=4;
noise_std_detect = median(abs(xf_detect))/0.6745;
thr = stdmin * noise_std_detect;        %thr for detection is based on detect settings.

[afHist,afCent]= hist(xf_detect, 1000);
afHist = afHist/sum(afHist);
fMean = mean(xf_detect);
fMedian = median(xf_detect);
fStd= std(xf_detect);
fStdMad= mad(xf_detect);
afNorm = normpdf(afCent, fMean,fStd);
afNorm=afNorm/sum(afNorm);
afNormMed = normpdf(afCent, fMedian,fStdMad);
afNormMed =afNormMed /sum(afNormMed );
figure(11);
clf;
plot(afCent,cumsum(afHist));
hold on;
plot(afCent,cumsum(afNorm),'r');
plot(afCent,cumsum(afNormMed),'g');

% Fit a student t- distribution?


N=500000;

plot(x(1:N),'b');
figure(12);
clf;
plot(xf_detect(1:N),'b');
hold on;
plot([0 N],ones(1,2)*thr,'r');

plot([0 N],-ones(1,2)*thr,'r');

