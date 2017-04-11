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

function [ STOVICAL_Results ] = removeduplicatesAnalysisResult( LabelPath2Set, STOVICAL_Results, varargin )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
    
%%
    p = inputParser;
    
    validate_keep = @(x) ismember(x,{'last','first'});
    
    addRequired(p,'keep',validate_keep);
    %parse(p,LabelPath2Set,STOVICAL_Results,varargin{:});
    parse(p,varargin{:});

%% Check if there are values to override
    IDX_dupl = find(ismember(STOVICAL_Results.LabelPath,LabelPath2Set));
    if isempty(IDX_dupl)
        return;
    end
    
    IDX_keep = find(ismember(STOVICAL_Results.LabelPath,LabelPath2Set),1,p.Results.keep);
    
    IDX_kill = setdiff(IDX_dupl,IDX_keep);
    if isempty(IDX_kill)
        return;
    end
    
%% Add / Replacement of Values
    STOVICAL_Results.LabelPath(IDX_kill) = [];
    STOVICAL_Results.Values(   IDX_kill) = [];
    
end

