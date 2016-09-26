% getPossibleDefinedLabels returns possible tokens
%
% Syntax:  [ possibleTokens, count, problemcases ] = getPossibleDefinedLabels( str_model )
%
% Inputs:
%    str_model - 
%
% Outputs:
%    possibleTokens - 
%    count - 
%    problemcases - 
%
% Example: 
%
% See also: getLabelDefinitionFromModelWorkspace, getDefinedLabelRegExp,
% getDefaultLabelDefinition, getJoinedSignals

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

function [ possibleTokens, count, problemcases ] = getPossibleDefinedLabels( str_model )

% Finde alle "Leitungen" in allen Varianten etc.
[BlockPaths2] = find_system(str_model,...
    'FindAll','on',...
    'LookUnderMasks','on',...
    'LoadFullyIfNeeded','on',...
    'RegExp','on',...
    'Variants','AllVariants',...
    'Name','#'...
    );

% Ermittle die Namen der Blöcke mit mindestens 1 #
Names = get_param(BlockPaths2,'Name');
if ~iscell(Names)
    Names = {Names};
end

% Dampfe zusammen auf identische
UniqueNames = unique(Names);

PositionsFound = strfind(UniqueNames,'#');

NrOfFound = cellfun(@length,PositionsFound);

filt_markers_one  = NrOfFound == 1;
filt_markers_two  = NrOfFound == 2;
filt_markers_more = NrOfFound >  2;

filt_markers_mode_even = filt_markers_more & mod(NrOfFound,2) == 0;
filt_markers_mode_odd  = filt_markers_more & ~filt_markers_mode_even;

%% Easy first try

filt_markers_morethan1 = filt_markers_two | filt_markers_more;

Names2Check = UniqueNames(filt_markers_morethan1);

for iStr = 1:size(Names2Check,1)
    SplitString{iStr,1} = strsplit(Names2Check{iStr},'#');
end

if size(Names2Check,1) > 0
    getonlyenclosedTokens = cellfun(@(x) x(2:(end-1)),SplitString,'UniformOutput',false);

    allTokens = transpose([getonlyenclosedTokens{:}]);

    [uniqueTokens,ia,ib] = unique(allTokens);

    countTokens = histc(ib,1:length(uniqueTokens));

    [~,srtidx] = sort(countTokens,'descend');

    %% return sortet with descending count

    possibleTokens = uniqueTokens(srtidx);
    count          = countTokens( srtidx);
else
    possibleTokens = {};
    count = {};
end

problemcases   = UniqueNames(filt_markers_one);

end

