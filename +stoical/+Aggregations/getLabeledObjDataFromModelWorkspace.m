% getLabeledObjDataFromModelWorkspace returns information about stoical model structure
%
% Syntax:  [ DATA ] = getLabeledObjDataFromModelWorkspace( system2load )
%
% Inputs:
%    system2load - simulink model name 
%
% Outputs:
%    DATA - information about model structure
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%
% See also: getActiveConfigurationAndParameters

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

function [ DATA ] = getLabeledObjDataFromModelWorkspace( system2load )

    % Get Defined Labels
        [DATA.LabelDefinition, IsDefault] = stoical.Label.getLabelDefinitionFromModelWorkspace( system2load, stoical.InternalDataStorage.getToolboxName() );

    % Get VS from File
        DATA.VariantDefinition      = stoical.VariantSubsystems.modelworkspaceoperations.getVariantsFromModelWorkspace(  system2load, stoical.InternalDataStorage.getToolboxName(), ...
                                        'tryUpdatingRelevantOnly', true );

    % Get Parameter Defs from Model Workspace
        DATA.ParameterDefinition    = stoical.Parameters.getParametersFromModelWorkspace(system2load, stoical.InternalDataStorage.getToolboxName() );
        
    % Get Log Signals from Model Workspace
        DATA.SignalDefinition       = stoical.Signals.modelworkspaceoperations.getSignalsFromModelWorkspace(system2load, stoical.InternalDataStorage.getToolboxName());
        
    % Get Signal Logging Output Options from Model Workspace
        DATA.SignalSaveOptions      = stoical.Signals.modelworkspaceoperations.getLoggingOptionsFromModelWorkspace(system2load, stoical.InternalDataStorage.getToolboxName());


end

