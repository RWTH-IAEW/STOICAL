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

function [ successfull ] = writeAllLoggedSignals2DB( Db, ResultTable, LoggedSignals, SignalLogNames, ActiveSetting, SimulationIdentifier, FixedStepTimeWindow )
%WRITEALLLOGGEDSIGNALS2DB Summary of this function goes here
%   Detailed explanation goes here

%% Get Options for Data Reduction
    if nargin < 7
        FixedStepTimeWindow = [0 Inf 5E-5];
        useWindow = false;
        discardTime = false;
    else
        useWindow = true; %HARDCODE
        discardTime = true; %HARDCODE
    end

%% Get Naming conventions for files, folders and data structures
    [ Prefixes, Suffixes ] = getVariablePrefixes();

%% Create Keys for Database

    VariantSetCell   = {[Prefixes.VariantSets           getmd5( ActiveSetting.ActiveVariantSet.AllEntriesValueString.All)           ]};

    ParameterSetCell = {[Prefixes.ParameterSets         getmd5( ActiveSetting.ActiveParametersSet.AllEntriesValueString.All)        ]};

    ModelConfSetCell = {[Prefixes.ModelConfigurationSet getmd5( ActiveSetting.ActiveSimulinkConfigurationSet.AllEntriesValueString.All)]};

    SPSConfSetCell   = {[Prefixes.SPSConfigurationSet   getmd5( ActiveSetting.ActiveSimPowerSystemsConfigSet.AllEntriesValueString.All)]};
    
    SimID            = {SimulationIdentifier};
        
%%    
    % Don't save structs as it is not supported yet by DB tools (Bus Signals Logged are structs)
        filt_isstruct = cellfun(@isstruct,LoggedSignals);
        
    successfull = false(size(filt_isstruct));
        
    %write per signal: 2-3x FASTER than writing in one go
        for iSig = 1:length(filt_isstruct)
            if filt_isstruct(iSig)
                % Bus Objects are not currently supported !!!
                warning([getToolboxName() ': Bus Objects are not currently supported !!!']);
                continue;
            end
            
            successfull(iSig,1) = writeSignal2DbFlexible( Db, ResultTable, LoggedSignals(iSig,:),...
                             ... Control Data Reduction by windowing & time discarding
                             'FixedStepTimeWindow', FixedStepTimeWindow, ... 
                             'UseWindow',       useWindow, ... 
                             'DiscardTime',     discardTime, ...
                             ...
                             'Signal',          SignalLogNames(iSig,:),  ...
                             'VariantSet',      VariantSetCell,  ...
                             'ParameterSet',    ParameterSetCell,...
                             'ModelConfigSet',  ModelConfSetCell,...
                             'SPSConfigSet',    SPSConfSetCell,   ...
                             'SimulationID',    SimID ...     
                             );

        end
            
end

