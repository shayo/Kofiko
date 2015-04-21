astrctTemp=dir('E:\Data\Doris\Data For Publications\Sinha\AllControls and contrast inversion\*StandardFOB_v2.mat');
k=56
for k=1:length(astrctTemp)
    load(['E:\Data\Doris\Data For Publications\Sinha\AllControls and contrast inversion\',astrctTemp(k).name])
   figure(11);clf;imagesc(strctUnit.m_a2fAvgFirintRate_Stimulus);colormap jet;set(gca,'ylim',[1 96]); 
   title(num2str(k));
   pause;
end

strKofikoFile = 'E:\Data\Doris\Electrophys\Houdini\Sinha_Project\Sessions\Controls\100907\100907_090938_Houdini.mat';
strPlexonFile = 'E:\Data\Doris\Electrophys\Houdini\Sinha_Project\Sessions\Controls\100907\100907_090938_Houdini_part_3.plx';
 [adfreq, n, ts, fn, ad] =plx_ad_v(strPlexonFile);
