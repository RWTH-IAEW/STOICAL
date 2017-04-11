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

function [ STOVICAL_Lookup ] = delLookupExperiments( Experiments2Delete, STOVICAL_Lookup )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
%   
%   no error checking here --> cheap and fast

%% Check if anything to delete

    if isempty(Experiments2Delete)
        return;
    end

    if islogical(Experiments2Delete)
        if length(Experiments2Delete) ~= STOVICAL_Lookup.NrOfExperiments
            error('Wrong size of delete filter');
        end
        if ~any(Experiments2Delete)
            return;
        end
    end
    
    if isnumeric(Experiments2Delete)
        tmp_filt = false(1,STOVICAL_Lookup.NrOfExperiments);
        tmp_filt(Experiments2Delete) = true;
        Experiments2Delete = tmp_filt;
    end
    
%% Catch initial situation
    if isfield(STOVICAL_Lookup,'Variant')
        hasVariants = true;
    else
        hasVariants = false;
    end
    
    if isfield(STOVICAL_Lookup,'Parameter')
        hasParameters = true;
    else
        hasParameters = false;
    end
    
%% Delete Experiments
    if hasVariants
        STOVICAL_Lookup.Variant.Values = ...
            cellfun(@(x) x(~Experiments2Delete),STOVICAL_Lookup.Variant.Values,'UniformOutput',false);
    end
    
    if hasParameters
        STOVICAL_Lookup.Parameter.Values = ...
            cellfun(@(x) x(~Experiments2Delete),STOVICAL_Lookup.Parameter.Values,'UniformOutput',false);
    end
    
    STOVICAL_Lookup.NrOfExperiments = sum(~Experiments2Delete);
    
end

