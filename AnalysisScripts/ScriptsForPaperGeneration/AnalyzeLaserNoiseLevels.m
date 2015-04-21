strFile = 'D:\Data\Doris\Data For Publications\FEF Opto\Laser_Stability_Test_03_June_2013_2.plx';
[adfreq1, n1, ts1, fn1, ad1] =plx_ad_v(strFile,29);
[adfreq2, n2, ts2, fn2, ad2] =plx_ad_v(strFile,28);

astrctStimulations = fnGetIntervals(ad1 > 0.2);
iNumPulses = length(astrctStimulations);
a2fData = zeros(iNumPulses, 3001);
for k=1:iNumPulses
a2fData(k,:) = ad2(astrctStimulations(k).m_iStart-500:astrctStimulations(k).m_iStart+2500);
end
afTime = [-500:2500] / 4000 ;
afMean = mean(a2fData,1);
afStd = std(a2fData,[],1);
figure(11);
clf;hold on;
plot(afTime,afMean+afStd,'color',[0.5 0.5 0.5]);
plot(afTime,afMean-afStd,'color',[0.5 0.5 0.5]);
plot(afTime,afMean,'k');

set(gca,'xlim',[-100 600],'ylim',[0 0.6],'xtick',[ 0 .5],'yticklabel',[]);
set(gca,'