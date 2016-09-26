% getSimulationIdentifier returns unique simulation identifier for active setting
%
% Syntax: 
% [ SimulationIdentifier ] = getSimulationIdentifier( thisActiveSetting, actualIterationNo )
% [ SimulationIdentifier ] = getSimulationIdentifier( thisActiveSetting, actualIterationNo, jobIdentifier )
%
% Inputs:
%    thisActiveSetting - current active setting
%    actualIterationNo - current iteration 
%    jobIdentifier - optional identifier for parallel job
%
% Outputs:
%    SimulationIdentifier - unique identifier of current active settings
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    thisActiveSetting = getActiveConfigurationAndParameters( STOICAL_MODEL, STOICAL );
%    sim_name = getSimulationIdentifier( thisActiveSetting, iRun );
%
% returns a unique simulation identifier by calculating md5 hash for active
% setting and adding simulation prefix.
% 
% See also: getLabeledObjDataFromModelWorkspace, getActiveConfigurationAndParameters, getVariablePrefixes

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

function [ SimulationIdentifier ] = getSimulationIdentifier( thisActiveSetting, actualIterationNo, jobIdentifier )

%% check for parfor case (multiple jobs)
    if nargin < 3
        jobIdentifier = num2str(1);
    else
        if isnumeric(jobIdentifier)
            jobIdentifier = num2str(jobIdentifier);
        end
    end

%% Get Naming conventions for files, folders and data structures
    [ Prefixes, Suffixes ] = stoical.InternalDataStorage.getVariablePrefixes();

%% Define Simulation Name
        
        fieldsOfActiveSetting = fieldnames(thisActiveSetting);
        if ~iscell(fieldsOfActiveSetting)
            fieldsOfActiveSetting = {fieldsOfActiveSetting};
        end
        
        NrOfFields = length(fieldsOfActiveSetting);
        
        DescriptiveString = cell(1,NrOfFields);

        for iConfSet = 1:NrOfFields
            DescriptiveString{1,iConfSet} = thisActiveSetting.(fieldsOfActiveSetting{iConfSet}).AllEntriesValueString.All;
        end

        if ~ischar(actualIterationNo)
            actualIterationNo = num2str(actualIterationNo);
        end
        
        sim_md5 = stoical.General.getmd5([strjoin(DescriptiveString,'') ...
                          datestr(now) actualIterationNo jobIdentifier]);
                      
        SimulationIdentifier = [Prefixes.Simulation sim_md5];

end

