function [I, varargout] = fnReadImageWrapper(strFileName)
bMatrix = fnIsMatrix(strFileName);
if ~bMatrix
	I = imread(strFileName);
	if strcmp(class(I),'uint16')
		% Rescale to uint8
		warning off;
		I = uint8(double(I) / 65535 * 255);
		warning on;
	end
else
	theFile = load(strFileName,'im','Clut');
	I = theFile.im;

	if strcmp(class(I),'uint16')
		%acImages{iFileIter} = I;
		I = double(I);
	end
	varargout{1} = theFile.Clut;
	
end
return;
end



function bMatrix = fnIsMatrix(strFileName)
[~, ~, strExt]=fileparts(strFileName);
bMatrix = strcmpi(strExt,'.mat');
return;
end