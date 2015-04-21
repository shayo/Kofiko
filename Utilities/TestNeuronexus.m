NumDataPoints = 100000;
SubData = zeros(iNumChannels, NumDataPoints);
[b,a]=butter(2,highPassRange*2/info.header.sampleRate,'bandpass');
for ch=1:iNumChannels
    [data, timestamps, info] = load_continuous_data(acChannelFiles{ch});
    subdata_uV_raw = data(1:NumDataPoints)*info.header.bitVolts;
    SubData(ch,:) = filtfilt(b,a,subdata_uV_raw);
end

astrctFiles = dir('C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\2014-04-10_16-09-26\*.continuous');
for k=1:length(astrctFiles)
    [d,t,h]=load_continuous_data(['C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\2014-04-10_16-09-26\',astrctFiles(k).name]);
    figure(11);
    clf;
    plot(d);
    pause
end


unique(d)
[d,t,h]=load_continuous_data('C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\2014-04-10_15-49-25\100_CH33.continuous');
[d,t,h]=load_continuous_data('C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\2014-04-10_15-49-25\100_ADC3.continuous');
figure;
plot(d)


figure(11);
clf;
hold on;
Centers=zeros(1,iNumChannels);
VoltageRange = 20:200;
for k=1:iNumChannels
    Centers(k)=100*k;
    CenterLabels{k} = sprintf('CH%d',k);
    plot(100*k+SubData(k,:));
    Hist(k,:)=histc(SubData(k,:),VoltageRange);
end
set(gca,'ytick',Centers,'yticklabel',CenterLabels);

figure(13);
clf;
plot(SubData(10,:))

figure(12);
clf;
for k=1:iNumChannels
    bar(VoltageRange,sum(Hist));
end
xlabel('Voltage (uV)');
ylabel('Num time points');
plot(SubData(20,:));


A=[
3.59E+07
3.87E+06
8.15E+06
3.11E+06
7.67E+06
3.56E+06
8.79E+06
4.21E+06
2.77E+07
1.01E+07
9.43E+06
9.05E+06
9.35E+06
9.63E+06
7.87E+06
8.30E+06
1.73E+07
8.77E+06
9.92E+06
9.50E+06
9.20E+06
8.59E+06
9.35E+06
8.50E+06
3.48E+06
7.28E+06
3.66E+06
7.45E+06
3.59E+06
8.31E+06
3.30E+06
8.96E+06];

B=[
3.20E+07
6.72E+05
1.33E+06
6.02E+05
1.16E+06
5.83E+05
1.26E+06
6.63E+05
3.53E+07
1.18E+06
1.24E+06
1.18E+06
1.14E+06
1.18E+06
1.17E+06
1.18E+06
1.56E+07
1.20E+06
1.11E+06
1.16E+06
9.66E+05
1.30E+06
1.26E+06
1.29E+06
6.56E+05
1.28E+06
5.82E+05
1.13E+06
5.83E+05
1.17E+06
6.71E+05
1.20E+06
2.89E+05
4.68E+02
4.64E+02
4.54E+02
4.51E+02
4.47E+02
4.52E+02
4.51E+02
4.44E+02
4.44E+02
4.35E+02
4.45E+02
4.57E+02
4.29E+02
4.06E+02
4.03E+02
3.99E+02
3.94E+02
4.20E+02
4.35E+02
4.41E+02
6.67E+06
8.03E+06
4.45E+02
4.41E+02
4.62E+02
4.58E+02
4.64E+02
4.57E+02
4.54E+02
4.69E+02
4.77E+02];

figure(13);clf;
hold on;
bar(B(1:32)/1e6,'b');
xlabel('Channel');
ylabel('Impedance (Mohm @ 1kHz)');
set(gca,'xlim',[0 33]);
set(gca,'ylim',[0 2]);


figure(13);clf;
hold on;
bar(A(1:32)/1e6,'b');
xlabel('Channel');
ylabel('Impedance (Mohm @ 1kHz)');
set(gca,'xlim',[1 32]);