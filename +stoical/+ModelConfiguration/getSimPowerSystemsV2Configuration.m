% getSimPowerSystemsV2Configuration returns information about active simulink SimPowerSystems model configuration
%
% Syntax: ActiveSimPowerSystemsConfigSet = getSymPowerSystemsV2Configuration( systemname )
%
% Inputs:
%    systemname - simulink model name
%
% Outputs:
%    ActiveSimPowerSystemsConfigSet - active SimPowerSystems configuration set
%
% Example:
%    STOICAL_MODEL = 'STOICAL_example_1'
%    ActiveSimPowerSystemsConfigSet = getSymPowerSystemsV2Configuration( STOICAL_MODEL );
%
% See also: getActiveConfigurationAndParameters, getSimulinkModelConfiguration

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

function [ ActiveSimPowerSystemsConfigSet ] = getSimPowerSystemsV2Configuration( system2lookup )
%GETSYMPOWERSYSTEMSV2CONFIGURATION Summary of this function goes here
%   Detailed explanation goes here

% TODO: skip eval, as num2str uses eval !!!!

nrformatunified = '%20.15e';

delimiter = '|';

%% Define the Parameters of Relevance

RelevantSPSParams = {...
    'SimulationMode',...
    'SolverType',...
    'SampleTime',...
    'frequency',...
    'SPID',...
    'DisableSnubberDevices',...
    'DisableRonSwitches',...
    'DisableVfSwitches',...
    'SwTol',...
    'Interpol',...
    'x0status'...
    };

RelevantSPSParams = reshape(RelevantSPSParams,[],1);

%% Find the SPS Options Block
% First, try top level occurence (fastest)
SPS_OptionsBlock = find_system(system2lookup,...
    'SearchDepth',1,...
    'MaskType','PSB option menu block'...
    );
if isempty(SPS_OptionsBlock)
    % Make another try with deeper searching (for example if powergui
    % block is contained in variant subsystem
    SPS_OptionsBlock = find_system(system2lookup,...
        'SearchDepth',3,...
        'MaskType','PSB option menu block'...
        );
end

if isempty(SPS_OptionsBlock)
    %nothing found ...
    ActiveSimPowerSystemsConfigSet = struct();
    
    ActiveSimPowerSystemsConfigSet.NrOfEntries = 0;
    
    
    ActiveSimPowerSystemsConfigSet.EntryValue.Mixed   = cell(0,1);
    ActiveSimPowerSystemsConfigSet.EntryValue.String  = cell(0,1);
    ActiveSimPowerSystemsConfigSet.EntryValue.Numeric = cell(0,1);
    
    ActiveSimPowerSystemsConfigSet.EntryValue.Names   = cell(0,1);
    
    ActiveSimPowerSystemsConfigSet.AllEntriesValueString.BuildRelevant    = '';
    ActiveSimPowerSystemsConfigSet.AllEntriesValueString.NotBuildRelevant = '';
    ActiveSimPowerSystemsConfigSet.AllEntriesValueString.All              = '';
    
    return;
end

%% Get the values as is
RelevantValues = cell(size(RelevantSPSParams,2),1);
for iVar = 1:length(RelevantSPSParams)
    RelevantValues{iVar,1} = get_param(SPS_OptionsBlock{1},RelevantSPSParams{iVar});
end

% Try to eval the parameters left as strings
EvaledParams = cell(size(RelevantSPSParams,2),1);
for iVar = 1:length(RelevantSPSParams)
    try
        EvaledParams{iVar,1} = eval(get_param(SPS_OptionsBlock{1},RelevantSPSParams{iVar}));
    catch
        EvaledParams{iVar,1} = [];
    end
end
filt_isevaled = ~cellfun(@isempty,EvaledParams);
RelevantValues(filt_isevaled) = EvaledParams(filt_isevaled);

RelevantValuesMixed = RelevantValues;

% Replace numerical values with unified formating
filt_isnumeric = cellfun(@isnumeric,RelevantValues);
NumVals = cell(size(RelevantSPSParams,2),1);
NumVals(filt_isnumeric,1) = RelevantValues(filt_isnumeric);
NumValsUniqueStr = cellfun(@(x) sprintf(nrformatunified,x),NumVals(filt_isnumeric,:),'UniformOutput',false);
RelevantValues(filt_isnumeric) = NumValsUniqueStr;

RelevantValuesString = RelevantValues;

%% Give back in default structure

ActiveSimPowerSystemsConfigSet.NrOfEntries = length(RelevantValuesMixed);


ActiveSimPowerSystemsConfigSet.EntryValue.Mixed   = RelevantValuesMixed;
ActiveSimPowerSystemsConfigSet.EntryValue.String  = RelevantValuesString;

ActiveSimPowerSystemsConfigSet.EntryValue.Numeric = cell(size(ActiveSimPowerSystemsConfigSet.EntryValue.Mixed));
ActiveSimPowerSystemsConfigSet.EntryValue.Numeric( filt_isnumeric,:) = ...
    ActiveSimPowerSystemsConfigSet.EntryValue.Mixed( filt_isnumeric,:);

ActiveSimPowerSystemsConfigSet.EntryValue.Names   = RelevantSPSParams;

ActiveSimPowerSystemsConfigSet.AllEntriesValueString.BuildRelevant    = ...
    strjoin(reshape(RelevantValuesString,1,[]),delimiter);
ActiveSimPowerSystemsConfigSet.AllEntriesValueString.NotBuildRelevant = '';
ActiveSimPowerSystemsConfigSet.AllEntriesValueString.All              = ...
    strjoin(reshape(RelevantValuesString,1,[]),delimiter);

end

