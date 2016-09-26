% path2labelstring 
%
% Syntax:  [ labelstring ] = path2labelstring( blkpath, labelsregexp )
%
% Inputs:
%    blkpath - 
%    labelsregexp -
%
% Outputs:
%    labelstring - 
%
% Example: 
%
% See also: l2p, labelstring2path,

% STOICAL - A Toolbox for Efficient Parameter and Structure Variation of Simulation Models in Simulink
% Copyright (C) 2015 Tilman Wippenbeck, Institute for High Voltage Technology, RWTH Aachen University
% 
% This file is part of STOICAL.
% 
% STOICAL is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% at your option any later version.
%
% STOICAL is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>. 

function [ labelstring ] = path2labelstring( blkpath, labelsregexp )

    % Eliminate Linebreaks
    expression = '[\n\r]';
    replace = ''; % Wodurch Zeilenumbrüche ersetzt werden sollen
    blkpath = regexprep(blkpath,expression,replace);

    pathparts = strsplit(blkpath,'/','CollapseDelimiters',false); %CRITICAL : was true, now is false
    
    matchpos = regexp(pathparts,labelsregexp);
    
    islabeled = ~cellfun(@isempty,matchpos);
    
    islastalabel = islabeled(end) == 1;
    
    lastlabel = find(islabeled,1,'last');
    if isempty(lastlabel)
        lastlabel = 0;
    end
    
    abbrev_pathparts = regexprep(pathparts,labelsregexp,'');
    
    abbr_path = strjoin(abbrev_pathparts(islabeled),'#');

    if ~isempty(abbr_path)
        abbr_path = ['#' abbr_path];
    end
    
    if ~islastalabel
        if ~isempty(abbr_path)
            abbr_path = strjoin({abbr_path pathparts{(lastlabel+1):end}},'/');
        else
            abbr_path = blkpath;
        end
    end
    
    labelstring = abbr_path;

end

