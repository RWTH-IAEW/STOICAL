% getActiveParametersFromCatalogue - 
%
% Syntax:  [ ParameterLabelpath, ActiveParameters ] = getActiveParametersFromCatalogue( paramlabelpathregexp, RelevantSimulationNames, Overview )
%
% Inputs:
%    paramlabelpathregexp - 
%    RelevantSimulationNames - 
%    Overview - 
%
% Outputs:
%    ParameterLabelpath - 
%    ActiveParameters - 
%
% Example: 
%
%
% See also: getActiveVariantsFromCatalogue,
% getSignalSimulationsMapFromCatalogue, writeActiveSetting2OverviewFile, loadCatalogue
%

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

function [ ParameterLabelpath, ActiveParameters ] = getActiveParametersFromCatalogue( paramlabelpathregexp, RelevantSimulationNames, Overview )

    %% Reverse mapping for information retrieval on result configuration basis
        MapRelevant2OverviewSimulationIdx = mapNonuniqueAtoUniqueB(RelevantSimulationNames, Overview.SimulationIDs);
    
    %% get some examaple PARAMETER data for the relevant configurations
    
        %TODO: make it even nicer !!!
        filt_paramfound = ~cellfun(@isempty,regexp(Overview.ActiveParametersSet.Labelpath, paramlabelpathregexp));
        
        % multi-row example
        ROWS = find(filt_paramfound);
        COLS = MapRelevant2OverviewSimulationIdx;
        
        ActiveParameters = Overview.ActiveParametersSet.EntryValue.Mixed(ROWS, COLS);

        ParameterLabelpath = Overview.ActiveParametersSet.Labelpath(filt_paramfound);
        
end

