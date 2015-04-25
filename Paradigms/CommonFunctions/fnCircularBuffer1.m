function [varargout] = fnCircularBuffer(Command, strct,subStruct,conditionIndex,varargin)

% 4 dimensional circular buffer
% stores or gets data regarding trial type, trial number in reverse order from last displayed trial of that type,
% all spikes or events in that trial, and all data associated with each spike or event in that trial

% Command types: 'put', 'get'
% put will add the data to the circular buffer, where data is specified by varargin{1}
% get will get the last n entries in the indices sent in conditionIndex, where n is the number specified by varargin{1}

% format is: [trial type, trial number, spike/event number, spike/event data]

% Struct is the top level struct to get the data from
% subStrct is the array/structure within the top level structure which holds the circular buffer
% conditionIndex is the condition to add the data to.
%

% add any structures you want to have a circular buffer in here. This function only supports 1 nested structure currently
% indexing or adding to a global structure is more memory and cpu efficient than passing the structure back and forth
global g_strctPlexon

switch Command
    
    
    case 'put'
        switch strct
            case 'g_strctPlexon'
                %%for iData = 1:size(Data,1)
                %g_strctPlexon.m_afSpikeBuffer.m_aiCircularBuffer = zeros(20,400,100,4);
                
                if g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex) > g_strctPlexon.(subStruct).m_iTrialsToKeepInBuffer
                    g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex) = 1;
                    
                    
                end
                g_strctPlexon.(subStruct).m_aiCircularBuffer(conditionIndex,g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex)...
                    ,1:size(varargin{1},1),:) =  varargin{1};
                
                g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex) = ...
                    g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex) + 1;
                
                %{
                    
                    
				g_strctPlexon.(subStruct).m_aiCircularBuffer(conditionIndex,g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex):...
											g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex)+(size(Data,1)-1),:) = ...
												Data;
                    %}
                    %end
                    
        end
    case 'get'
        switch strct
            case 'g_strctPlexon'
                numElementsToExtract =  varargin{1};
                
                for i = 1:size(conditionIndex,2)
                    if g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex(i)) - varargin{1} <= 0
                        
                        BufferIDs = ...
                            [1:g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex(i)),fliplr((g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex(i)) - varargin{1}+1 +...
                            size(g_strctPlexon.(subStruct).m_aiCircularBuffer,2)):size(g_strctPlexon.(subStruct).m_aiCircularBuffer,2))];
                        varargout{1}(conditionIndex(i),1) = BufferIDs;
                        %varargout{1}(conditionIndex(i),1:varargin{1},:,:) = [conditionIndex(i),BufferIDs)
                        %varargout{1}(conditionIndex(i),1:varargin{1},:,:) = g_strctPlexon.(subStruct).m_aiCircularBuffer(conditionIndex(i),BufferIDs,:,:);
                        
                    else
                        varargout{1}(i,1:numElementsToExtract,:,:) = g_strctPlexon.(subStruct).m_aiCircularBuffer(i,...
                            [((g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex(i))-1) -...
                            varargin{1}+1:g_strctPlexon.(subStruct).m_aiCircularBufferIndices(conditionIndex(i))-1)],:,:);
                    end
                end
                %{
                    for i = 1:size(buffer,2)
                        if bufferIDs(i) - numElementsToExtract <= 0
                            dataIDs = [1:bufferIDs(i), (bufferIDs(i) - numElementsToExtract+1)+size(buffer,3):size(buffer,3)];
                            data(:,i,1:numElementsToExtract) = buffer(:,i,dataIDs);
                        else
                            data(:,i,1:numElementsToExtract) = buffer(:,i,[bufferIDs(i)-numElementsToExtract+1:bufferIDs(i)]);
                        end
                    end
                %}
        end
        
        
        
        



end

return;