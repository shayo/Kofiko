fnDAQ('Init')

fnDAQ('SetBit',17,1);
WaitSecs(0.1);
N = 50;
fTimer = GetSecs();
afTimeBefore = zeros(1,N);
afTimeAfter = zeros(1,N);
k = 1;
while (1)
    fCurrTime = GetSecs();
    if fCurrTime-fTimer > k-(0.35 / 1e3)
        afTimeBefore(k) = fCurrTime;
        fnDAQ('StrobeWord',k);
        afTimeAfter(k) = GetSecs();
        fprintf('%d\n ',k);
        k=k+1;
        if k > N
            break;
        end
    end

end

fnDAQ('SetBit',17,0);


strctConfig = fnLoadConfigXML(fullfile('.', 'Config', 'SessionBrowser.xml'));
strctPlexon = fnReadPlexonFileAllCh('C:\PlexonKofikoSyncTest3.plx', strctConfig.m_strctChannels);

strctPlexon.m_strctStrobeWord.m_aiWords
afPlexonRelative = strctPlexon.m_strctStrobeWord.m_afTimestamp(1:end-1)-strctPlexon.m_strctStrobeWord.m_afTimestamp(1);
afKofikoRelative = afTimeAfter-afTimeAfter(1);


(afKofikoRelative-afPlexonRelative')*1e3

figure(2);
clf;hold on;
plot(0:100,0:100,'b*');
plot(afPlexonRelative,afPlexonRelative,'r.');
plot(afKofikoRelative,afKofikoRelative,'go');
legend('Real Time','Plexon','Kofiko');

figure(3);clf;
plot(1:100,afKofikoRelative-afPlexonRelative')

figure;
astrctIntervals = fnGetIntervals(strctPlexon.m_strctSync.m_afData>500);

afPlexonAnalog = cat(1,astrctIntervals.m_iStart) / strctPlexon.m_strctSync.m_fFreq;

afPlexonAnalogRelative = afPlexonAnalog-afPlexonAnalog(1);

afPlexonAnalog-