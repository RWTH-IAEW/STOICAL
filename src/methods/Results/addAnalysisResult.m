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

function [ STOVICAL_Results ] = addAnalysisResult( LabelPath2Set, Values, STOVICAL_Results )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

checkNeed2Overwrite = true;

%% Catch initial situation
    if nargin < 3
        STOVICAL_Results = struct();
        STOVICAL_Results.LabelPath = cell(1,0);
        STOVICAL_Results.Values    = cell(1,0);
        
        checkNeed2Overwrite = false;
    end
    
    if nargin == 3 
        if ~isfield(STOVICAL_Results,'LabelPath')
            STOVICAL_Results.LabelPath = cell(1,0);
            checkNeed2Overwrite = false;
        end
        if ~isfield(STOVICAL_Results,'Values')
            STOVICAL_Results.Values = cell(1,0);
            checkNeed2Overwrite = false;
        end
    end            
    
%% Check if there are values to override
    if checkNeed2Overwrite
        IDX = find(ismember(STOVICAL_Results.LabelPath,LabelPath2Set),1,'last');
        if isempty(IDX)
            IDX = size(STOVICAL_Results.LabelPath,2)+1;
        end
    else
        IDX = size(STOVICAL_Results.LabelPath,2)+1;
    end    
    
%% Add / Replacement of Values
    STOVICAL_Results.LabelPath{1,IDX} = LabelPath2Set;
    STOVICAL_Results.Values{   1,IDX} = Values;
    
end

