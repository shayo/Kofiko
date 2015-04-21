function strctUnit = fnAnalyzeFOBInv(strctUnit, strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)
dbg = 1;
% First, how much do the cell changes firing rate for individual stimuli,
% % and as a group
% 
% 1:16,
% 106:121
% 
% 
% 
% length(strctUnit.m_afAvgFirintRate_Stimulus)
% figure;
% plot(strctUnit.m_afAvgStimulusResponseMinusBaseline*1e3)
% 
% figure(11);
% clf;
% subplot(2,1,1);
% bar([strctUnit.m_afAvgFiringRateCategory(1:7);strctUnit.m_afAvgFiringRateCategory(8:14)]')
% legend('Normal','Inverted','Location','NorthEastOutside');
% set(gca,'xtick',1:7,'xticklabel', {'Faces'  'Bodies'  'Fruits'  'Gadgets'  'Hands'  'Scrambles'  'Face Side'});
% xticklabel_rotate
% subplot(2,1,2);
% hold on;
% for k=1:16
%     plot([0,1],[strctUnit.m_afAvgFirintRate_Stimulus(k),strctUnit.m_afAvgFirintRate_Stimulus(k+105)],'b');
% end
% figure;
% plot(strctUnit.m_afAvgFirintRate_Stimulus(1:105)-strctUnit.m_afAvgFirintRate_Stimulus(106:210))
%
return;
