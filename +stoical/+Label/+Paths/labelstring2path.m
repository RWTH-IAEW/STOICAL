% labelstring2path 
%
% Syntax:  [ blkpath, blkhdl ] = labelstring2path( labelstring, BlkHandles, varargin )
%
% Inputs:
%    labelstring - 
%    BlkHandles -
%
% Outputs:
%    blkpath - 
%    blkhdl - 
%
% Example: 
%
% See also: l2p, path2labelstring,

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

function [ blkpath, blkhdl ] = labelstring2path( labelstring, BlkHandles, varargin )
% V2: Ersatz NodeList.NodeHandle durch BlkHandles

%% Eingangsparameter SpecialParameters parsen
    p = inputParser;
    %               Name             DefVal   Type
    addParameter(p,'multiple'        ,false   ,@islogical);
    %parse(p,varargin{:});
    parse(p,varargin{:});

%%    

    % Eliminate Linebreaks
    expression = '[\n\r]';
    replace = ''; % Wodurch Zeilenumbrüche ersetzt werden sollen
    labelstring = regexprep(labelstring,expression,replace);
    % Whitespace eliminieren
    labelstring = regexprep(labelstring,'\s','');

    pathparts = strsplit(labelstring,'/');
    
    matchpos = strfind(pathparts,'#');
    hasraute = ~cellfun(@isempty,matchpos);
    
    if hasraute(1) == 0
        blkpath = labelstring;
        blkhdl  = get_param(blkpath,'Handle');
        return;
    end
    
    if size(pathparts,2) > 1
        %there are relative paths given after ev. labelstring
        relpath2search = ['/' strjoin(pathparts(2:end),'/')];
        relpath2search = strrep(relpath2search,'.*','((?!/)(.))*');
    else
        relpath2search = '';
    end
    
    if hasraute(1) == 1
        %this might be a labelstring
        foundposofraute = strfind(pathparts{1},'#');
        if foundposofraute(1) ~= 1
            %not a labelstring
            blkpath = labelstring;
            blkhdl  = get_param(blkpath,'Handle');
            return;
        else
            %is a labelstring
            labelstringcore = pathparts{1}(2:end);
            
            labelparts = strsplit(labelstringcore,'#');
            
            %get the paths of all nodes
            NodePaths = getfullname(BlkHandles);
            if ~iscell(NodePaths) % due to varying behaviour in dep of nr of results of getfullname
                NodePaths = {NodePaths};
            end
            
            
            % Handle Lines differently
                TypeOfObj = get_param(BlkHandles,'Type');
                if ~iscell(TypeOfObj) % due to varying behaviour in dep of nr of results of get_param
                    TypeOfObj = {TypeOfObj};
                end
                isline = cellfun(@(x) strcmp(x,'line'),TypeOfObj);
                
                if ~isempty(isline) && any(isline)

                    LineParent = get_param(BlkHandles(isline,1),'Parent');
                    LineName   = get_param(BlkHandles(isline,1),'Name');

                    LineComparePathNames = cellfun(@(x,y) [x '/' y],LineParent,LineName,...
                        'UniformOutput',false);

                    NodePaths(isline,:) = LineComparePathNames;
                end
            
            % Eliminate Linebreaks
            expression = '[\n\r]';
            replace = ''; % Wodurch Zeilenumbrüche ersetzt werden sollen
            NodePathsPlain = regexprep(NodePaths,expression,replace);
            NodePathsPlain = regexprep(NodePathsPlain,'\s','');
            
            % Substitute simple .* for ((?!/)(.))* in RegExp
            %labelparts = strrep(labelparts,'.*','((?!/)(.))*');
            %labelparts = strrep(labelparts,'.*','.*(?=/)');
            labelparts = strrep(labelparts,'.*','(.*(?=/)|((?!/)(.))*)');
            
            %prepare search patterns
            labelednames = cellfun(@(x) ['(#' x '|' x '#)'],labelparts,'UniformOutput',false);
            %labelednames = cellfun(@(x) ['(#' x '|' x '#)'],labelparts,'UniformOutput',false);
            %labelednames = cellfun(@(x) ['(#' x '((?!/)(.))*|' x '#((?!/)(.))*)'],labelparts,'UniformOutput',false);
            labelsearchpattern = strjoin(labelednames,'.+'); %Is this wrong?
            labelsearchpattern = strjoin(labelednames,'.*'); %Is this correct? % TODO
            %warning('Do extensive Tests on the regexp !!! ');
            
            %test = regexp(NodePathsPlain,[labelsearchpattern relpath2search '$']);
            addon = '(.*(?=/)|((?!/)(.))*)'; %new test
            test = regexp(NodePathsPlain,[labelsearchpattern relpath2search addon '$']);
            
            foundidx = find(~cellfun(@isempty,test));
            %NodeList.NodeName(foundidx)
            
            if isempty(foundidx)
                blkpath = '';
                blkhdl  = [];
                warning([stoical.InternalDataStorage.getToolboxName() ': No correspondig element found for given labelpath "' labelstring '" -> ignoring']);
            else
                if length(foundidx) == 1
                    blkpath = NodePaths{foundidx};
                    blkhdl  = BlkHandles(foundidx);
                else
                    if p.Results.multiple == false
                        warning([stoical.InternalDataStorage.getToolboxName() ': Set "multiple" to true if nescessary']);
                        error([stoical.InternalDataStorage.getToolboxName() 'Given labelstring does not resolve to unique path']);
                    else
                        blkpath = NodePaths(foundidx);
                        blkhdl  = BlkHandles(foundidx);
                    end
                end
        end
    end
    
end

