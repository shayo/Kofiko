function [afDepths,afMean, afStd,acSaccades,afSaccadeOnsets,afMeanDir,afDirStd]=fnAnaylzeSaccadeBeforeInjection(strctData,fPIX_TO_VISUAL_ANGLE)
afDepths = cat(1,strctData.strctStimStat.m_astrctStimulation.m_fDepth);
[afDepths, aiInd]=sort(afDepths);

strctData.strctStimStat.m_astrctStimulation=strctData.strctStimStat.m_astrctStimulation(aiInd);
iNumDepths = length(afDepths);
% figure(11);clf;
% set(11,'Color',[1 1 1]);
afSaccadeOnsets = [];
afSaccadeDirection = [];
for k=1:iNumDepths
    aiBaseLineRange = 1:200;
    aiSamplingRange = 200+ [150:200];
    a2fX = strctData.strctStimStat.m_astrctStimulation(k).m_a2fXpix;
    a2fY = strctData.strctStimStat.m_astrctStimulation(k).m_a2fYpix;
    abBlinks = abs(max(sqrt(a2fX.^2+a2fY.^2),[],2)) > 3000;
    afDistancePix = mean(sqrt(a2fX(:,aiSamplingRange).^2+a2fY(:,aiSamplingRange).^2),2);
    
    
%     figure;
%     plot(strctData.strctStimStat.m_astrctStimulation(k).m_a2fXpix')
    afBaselinePix = mean(sqrt(strctData.strctStimStat.m_astrctStimulation(k).m_a2fXpix(:,aiBaseLineRange).^2+strctData.strctStimStat.m_astrctStimulation(k).m_a2fYpix(:,aiBaseLineRange).^2),2);
    abOutliers = abBlinks | afBaselinePix > 40;
     
    a2fCleanData = sqrt((a2fX(~abOutliers,:)*fPIX_TO_VISUAL_ANGLE).^2+(a2fY(~abOutliers,:)*fPIX_TO_VISUAL_ANGLE).^2);
    afDistanceClean = mean(sqrt( a2fX(~abOutliers,aiSamplingRange).^2+a2fY(~abOutliers,aiSamplingRange).^2),2)*fPIX_TO_VISUAL_ANGLE;
    a2fXclean = a2fX(~abOutliers,:)*fPIX_TO_VISUAL_ANGLE;
    a2fYclean = a2fY(~abOutliers,:)*fPIX_TO_VISUAL_ANGLE;
    abSaccades = afDistanceClean>2;
    a2fSaccades = a2fCleanData(abSaccades,:);

if sum(abSaccades)>0
     a2fSaccades = a2fCleanData(abSaccades,:);
     a2fAngles = atan2(a2fYclean(abSaccades, aiSamplingRange),-a2fXclean(abSaccades, aiSamplingRange));

    afMeanDir(k)=circ_mean(a2fAngles(:))/pi*180;
    afDirStd(k)=circ_std(a2fAngles(:))/sqrt(prod(size(a2fAngles)))/pi*180;
else
    afMeanDir(k)=NaN;
    afDirStd(k)=NaN;
end

     acSaccades{k} = {a2fSaccades,a2fXclean,a2fYclean} ;
     
    if ~isempty(a2fSaccades)
        Tmp=a2fSaccades(:,100:200);
        fThres = mean(Tmp(:))+5*std(Tmp(:));
        for j=1:size(a2fSaccades,1)
            abLarger = a2fSaccades(j,:) > fThres;
            abLarger(1:230) = 0;
            astrctIntervals = fnGetIntervals(abLarger);
            if ~isempty(astrctIntervals)
            iIndex = find(cat(1,astrctIntervals.m_iLength) > 5,1,'first');
                if ~isempty(iIndex)
                    if strctData.strctStimStat.m_afRangeMS(astrctIntervals(iIndex).m_iStart) > 200
                        figure(11);
                        clf;
                        plot(a2fSaccades');
                        hold on;
                        plot(a2fSaccades(j,:),'r');
                        plot(ones(1,2)*astrctIntervals(iIndex).m_iStart,[0 20],'g--');
                        dbg = 1;
                    end
                    afSaccadeOnsets = [afSaccadeOnsets,strctData.strctStimStat.m_afRangeMS(astrctIntervals(iIndex).m_iStart);];
                end
            end
        end
    end
     
%     
%       subplot(6,6,k);
%      cla;
%      plot(-a2fX(~abOutliers,200:400)'*fPIX_TO_VISUAL_ANGLE,a2fY(~abOutliers,200:400)'*fPIX_TO_VISUAL_ANGLE,'k')
%      hold on;
%      plot(0,0,'r+');
%     axis([-40 40 -40 40]);
%     rectangle('position',[-35 -35 5 1],'facecolor','b');
%     set(gca,'xtick',[],'ytick',[])
    
    if sum(afDistanceClean>2) > 0
        afMean(k) = mean(afDistanceClean(afDistanceClean>2));
        afStd(k) = std(afDistanceClean(afDistanceClean>2))/sqrt(sum(afDistanceClean>2));
    else
        afMean(k) = mean(afDistanceClean);
        afStd(k) = std(afDistanceClean)/sqrt(length(afDistanceClean));
    end
    afMax(k) = max(afDistanceClean);
end
dbg = 1;