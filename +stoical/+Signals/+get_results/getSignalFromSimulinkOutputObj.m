% getSignalFromSimulinkOutputObj retrieves Simulink Timeseries from the
% STOICAL model for the specified labelpath
%
% Syntax:  [ SignalTimeSeries ] = getSignalFromSimulinkOutputObj( RegExp_Labelpath, STOICAL )
%
% Inputs:
%    RegExp_Labelpath - regular expression for specified label path
%    STOICAL - information about model structure
%
% Outputs:
%   SignalTimeSeries - simulink time series of specified signal
%
% Example:
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    eval([STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName ' = sim(STOICAL_MODEL);']);
%    [ Signal_Stimulus ] = getSignalFromSimulinkOutputObj( '#stimulus', STOICAL );
%
% See also: getLabeledObjDataFromModelWorkspace

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

function [ SignalTimeSeries ] = getSignalFromSimulinkOutputObj( RegExp_Labelpath, STOICAL )

% get Prefixes
[ Prefixes, Suffixes ] = stoical.InternalDataStorage.getVariablePrefixes();

% Determine the Signals logged
SignalLogNames = stoical.Signals.get_results.getOutputSignalContent( ...
    ... eval(STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName), ...
    evalin('caller',STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName), ...
    STOICAL.SignalSaveOptions.SignalLoggingName, Prefixes.Signals );

% Pick one specific out of all the logged ones
% determine which one is the right one
LogVarNames2get = stoical.Signals.get.getAllSignalNamesForLabel( RegExp_Labelpath, STOICAL.SignalDefinition, SignalLogNames);

% Retrieve all the logged Signals from result object
LoggedSignals = stoical.Signals.get_results.getOutputSignal( evalin('caller',STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName),...
    STOICAL.SignalSaveOptions.SignalLoggingName,LogVarNames2get);

% give back the signal of interest
SignalTimeSeries = LoggedSignals;

end

