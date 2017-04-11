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

function [ ResultData ] = getAnalysisResult( LabelPath2Get, STOVICAL_Results )
%GETANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

%% Identify Values to Return
%  make this more sophisticated!
    filt_found = ismember(STOVICAL_Results.LabelPath,LabelPath2Get);
    
%% Return of Values
    if sum(filt_found) > 1
        ResultData = STOVICAL_Results.Values(filt_found); %return as cell
    elseif sum(filt_found) == 1
        ResultData = STOVICAL_Results.Values{filt_found}; %return as whatever is inside cell
    else
        ResultData = []; % return empty structure
        warning([getToolboxName() ': Desired Results not found: "' LabelPath2Get '"']);
    end
    
%% Handle empty cellentries
    if iscell(ResultData)
        find_empty = cellfun('isempty',ResultData);
        
        if any(find_empty) && any(~find_empty)
            idx_nonempty = find(~find_empty,1,'first');
            if isnumeric(ResultData{idx_nonempty})
                ResultData(find_empty) = {ResultData{idx_nonempty}.*nan};
            else
                warning([getToolboxName() ': empty results found. Take care of cell2mat!']);
            end
        end
    end

end

