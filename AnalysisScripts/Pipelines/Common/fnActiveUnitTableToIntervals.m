function astrctUnitIntervals = fnActiveUnitTableToIntervals(a2fActiveUnitsTable, strctSync,strSession,strRawFolder)
if ~exist('strRawFolder','var') || (exist('strRawFolder','var') && isempty(strRawFolder))
    strRawFolder = [];
end
if ~exist('strSession','var') || (exist('strSession','var') && isempty(strSession))
    strSession = [];
end

if ~exist('strctSync','var') || (exist('strctSync','var') && isempty(strctSync))
    % Crappy sync mechanism....
    % Find the first unit and take the PLX time stamp for it.
    fprintf('Warning, Sync file is missing!!! synching according to MAP clock....\n');
    fZeroMAP= a2fActiveUnitsTable(1, 6); % MAP Clock...
    fZeroPlexon = a2fActiveUnitsTable(1, 4); % MAP Clock...
    bMAPclockSync = true;
else
    bMAPclockSync = false;
end

strStatServerFile = fullfile(strRawFolder,[strSession,'-StatServerInfo.mat']);
strctTmp = load(strStatServerFile);
aiMappingToRealChannelNumber = strctTmp.g_strctNeuralServer.m_aiActiveSpikeChannels;
a2fActiveUnitsTable(:,1) = aiMappingToRealChannelNumber(a2fActiveUnitsTable(:,1));

clear astrctUnitIntervals
NumEntries = size(a2fActiveUnitsTable,1);
iIntervalCounter = 0;
for iEntryIter=1:NumEntries
   if a2fActiveUnitsTable(iEntryIter,3) == 1
       % New interval defined!
       iIntervalCounter = iIntervalCounter + 1;
       astrctUnitIntervals(iIntervalCounter).m_strRawFolder = strRawFolder;
       astrctUnitIntervals(iIntervalCounter).m_strSession = strSession;
       astrctUnitIntervals(iIntervalCounter).m_iUniqueID = iIntervalCounter;
       astrctUnitIntervals(iIntervalCounter).m_iChannel = a2fActiveUnitsTable(iEntryIter,1);
       astrctUnitIntervals(iIntervalCounter).m_iUnit = a2fActiveUnitsTable(iEntryIter,2);
%       astrctUnitIntervals(iIntervalCounter).m_iPlexonFrame = a2fActiveUnitsTable(iEntryIter,4);
%        astrctUnitIntervals(iIntervalCounter).m_fStartTS_PLXframe = a2fActiveUnitsTable(iEntryIter,5);
%        astrctUnitIntervals(iIntervalCounter).m_fStartTS_MAP = a2fActiveUnitsTable(iEntryIter,6);
%        astrctUnitIntervals(iIntervalCounter).m_fStartTS_PTB_StatServer = a2fActiveUnitsTable(iEntryIter,7);
%        astrctUnitIntervals(iIntervalCounter).m_fStartTS_PTB_Kofiko = fnTimeZoneChange(a2fActiveUnitsTable(iEntryIter,7),strctSync,'StatServer','Kofiko');   
if bMAPclockSync
    fStartTS_MAP = a2fActiveUnitsTable(iEntryIter,6);
    astrctUnitIntervals(iIntervalCounter).m_fStartTS_Plexon= fStartTS_MAP-fZeroMAP + fZeroPlexon;
else
       astrctUnitIntervals(iIntervalCounter).m_fStartTS_Plexon= fnTimeZoneChange(a2fActiveUnitsTable(iEntryIter,7),strctSync,'StatServer','Plexon');   
end
%        astrctUnitIntervals(iIntervalCounter).m_fEndTS_PLXframe = NaN;
%        astrctUnitIntervals(iIntervalCounter).m_fEndTS_MAP = NaN;
%        astrctUnitIntervals(iIntervalCounter).m_fEndTS_PTB_StatServer = NaN;
%        astrctUnitIntervals(iIntervalCounter).m_fEndTS_PTB_Kofiko = NaN;
       astrctUnitIntervals(iIntervalCounter).m_fEndTS_Plexon = NaN;
       astrctUnitIntervals(iIntervalCounter).m_bStillOpen = true;
   else
       % Old interval closed.
       % find the relevant interval
       aiChannels = cat(1,astrctUnitIntervals.m_iChannel);
       aiUnits = cat(1,astrctUnitIntervals.m_iUnit);
%       aiPlexonFrames = cat(1,astrctUnitIntervals.m_iPlexonFrame);
       afStartTS_PLX = cat(1,astrctUnitIntervals.m_fStartTS_Plexon);

       iChannel = a2fActiveUnitsTable(iEntryIter,1);
       iUnit = a2fActiveUnitsTable(iEntryIter,2);
%       iPlexonFrame = a2fActiveUnitsTable(iEntryIter,4);
       
       
       if bMAPclockSync
           fEndTS_MAP = a2fActiveUnitsTable(iEntryIter,6);
           fEndTS_PLX= fEndTS_MAP-fZeroMAP + fZeroPlexon;
       else
           fEndTS_PLX = fnTimeZoneChange(a2fActiveUnitsTable(iEntryIter,7),strctSync,'StatServer','Plexon');
       end
       
       
       
       iOpenInterval  = find(aiChannels == iChannel & aiUnits == iUnit & afStartTS_PLX < fEndTS_PLX,1,'last');
       
       if isempty(iOpenInterval) 
           fprintf('Critical error ! cannnot find the start interval for this closing interval (%d)!\n',iEntryIter);
       else
           if astrctUnitIntervals(iOpenInterval).m_bStillOpen == false
               fprintf('Critical error ! the interval has been closed already (%d)!\n',iEntryIter);
           else
%             astrctUnitIntervals(iOpenInterval).m_fEndTS_PLXframe = a2fActiveUnitsTable(iEntryIter,5);
%             astrctUnitIntervals(iOpenInterval).m_fEndTS_MAP = a2fActiveUnitsTable(iEntryIter,6);
%             astrctUnitIntervals(iOpenInterval).m_fEndTS_PTB_StatServer = fEndTS_PTB;
%             astrctUnitIntervals(iOpenInterval).m_fEndTS_PTB_Kofiko = fnTimeZoneChange(fEndTS_PTB,strctSync,'StatServer','Kofiko');   
%             astrctUnitIntervals(iOpenInterval).m_fEndTS_Plexon = fnTimeZoneChange(fEndTS_PTB,strctSync,'StatServer','Plexon');   
             astrctUnitIntervals(iOpenInterval).m_fEndTS_Plexon =fEndTS_PLX;
             
            astrctUnitIntervals(iOpenInterval).m_bStillOpen = false;
           end
       end
        
       
   end
   
end

astrctUnitIntervals = rmfield(astrctUnitIntervals,'m_bStillOpen');
return;
