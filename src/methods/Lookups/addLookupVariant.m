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

function [ STOVICAL_Lookup ] = addLookupVariant( LabelPath2Set, Values, STOVICAL_Lookup )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
%   
%   no error checking here --> cheap and fast

%% Catch initial situation
    if nargin < 3
        STOVICAL_Lookup = struct();
        STOVICAL_Lookup.Variant = struct();
        STOVICAL_Lookup.Variant.LabelPath = cell(1,0);
        STOVICAL_Lookup.Variant.Values    = cell(1,0);
    end
    
    if nargin == 3
        if ~isfield(STOVICAL_Lookup,'Variant')
            STOVICAL_Lookup.Variant = struct();
        end
        if ~isfield(STOVICAL_Lookup.Variant,'LabelPath')
            STOVICAL_Lookup.Variant.LabelPath = cell(1,0);
        end
        if ~isfield(STOVICAL_Lookup.Variant,'Values')
            STOVICAL_Lookup.Variant.Values = cell(1,0);
        end
    end            
    
%% Check if there are values to override
    %TODO
    %now: append on default
    
%% Add of Values, Convert 2 String
    STOVICAL_Lookup.Variant.LabelPath{1,end+1} = LabelPath2Set;
    
    if ischar(Values)
        tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
        tmp(:) = {Values};
        STOVICAL_Lookup.Variant.Values{   1,end+1} = tmp;
    elseif iscell(Values)
        if length(Values) == 1 & STOVICAL_Lookup.NrOfExperiments > 1
            tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
            tmp(:) = Values;
            Values = tmp;
        end
        STOVICAL_Lookup.Variant.Values{   1,end+1} = Values;
    else
        if isnumeric(Values)
            if length(Values) == 1 & STOVICAL_Lookup.NrOfExperiments > 1
                tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
                tmp(:) = {Values};
                Values = tmp;
                STOVICAL_Lookup.Variant.Values{   1,end+1} = Values;
            else
                Values = num2cell(Values);
                STOVICAL_Lookup.Variant.Values{   1,end+1} = Values;
            end 
        end
    end    
    
end

