function [acImageIndices, acBlockNames] = fnLoadMRIStyleBlockList(strBlockList)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

try
    [acImageIndices, acBlockNames] = load_blocklist(strBlockList);
catch
    acImageIndices = [];
    acBlockNames = [];
end

return;


function [block_list, block_names] = load_blocklist(filename)
% Adopted from Sebastian's original code...
%
% read in the block names and the according image numbers
% this 'parser' allows for empty lines and will ignore lines starting with
% '#', so whole lines can be commented out
% filename: fully qualified name of the category list file
% block_names: cell array of the category names
% block_list: cell array of arrays, for each category a list of the image IDs

% fq_filename = fullfile(pwd, 'catlist_faces_objects_bodies_new.txt');
whitespace_symbol = '_';

n_blocks = 0;
block_fd = fopen(filename, 'r');
if (block_fd == -1),
	error([filename, ' does not seem to exist...']);
end

block_list = cell(1);
block_names = {};

while ~feof(block_fd),
	text_line = fgetl(block_fd);
	% skip empty lines
	if (isempty(text_line)),
		continue;
	end
	% skip comments
	if (text_line(1) == '#'),
		continue;
	end
	block_idx = findstr(text_line, 'Block');
	% new block...
	if (block_idx >= 1),
		n_blocks = n_blocks + 1;
		[token, remainder] = strtok(text_line);	% white space separation
		% get rid of leading and trailing whitespace
		tmp_block_names = strtrim(remainder);
		% exchange all internal white space characters...
		whitespace_idx = isspace(tmp_block_names);
		if (~isempty(whitespace_idx)),
			tmp_block_names(whitespace_idx) = whitespace_symbol;	% replace spaces
		end
		block_names{end + 1} = tmp_block_names; 
		img_pos = 0;
	else
		img_pos = img_pos + 1;
		block_list{n_blocks}(img_pos) = str2num(text_line);
	end
end

% clean up
fclose(block_fd);

return
