function [data] = fnGetDataFromTrialCircularBuffer(buffer, bufferIDs, numElementsToExtract)


for i = 1:size(buffer,2)
	if bufferIDs(i) - numElementsToExtract <= 0
		dataIDs = [1:bufferIDs(i), (bufferIDs(i) - numElementsToExtract+1)+size(buffer,3):size(buffer,3)];
		data(:,i,1:numElementsToExtract) = buffer(:,i,dataIDs);
	else
		data(:,i,1:numElementsToExtract) = buffer(:,i,[bufferIDs(i)-numElementsToExtract+1:bufferIDs(i)]);
	end

end

return;