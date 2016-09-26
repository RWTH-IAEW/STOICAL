% getActiveConfigurationAndParameters returns information about active settings of stoical model
%
% Syntax:  [ thisActiveSetting ] = getActiveConfigurationAndParameters( systemname, STOICAL )
%
% Inputs:
%    systemname - simulink model name 
%    STOICAL - information about model structure
%
% Outputs:
%    thisActiveSetting - struct of current active setting
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    thisActiveSetting = getActiveConfigurationAndParameters( STOICAL_MODEL, STOICAL );
%
% See also: getLabeledObjDataFromModelWorkspace, getSimulationIdentifier,
% setBuildAndCacheFolder, getSimulinkModelConfiguration, getSimPowerSystemsV2Configuration

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

function [ thisActiveSetting ] = getActiveConfigurationAndParameters( systemname, STOICAL )

    % ------------- Get Active Variant Set -------------
        thisActiveSetting.ActiveVariantSet = getActiveVariantSetFromBaseWorkspace( STOICAL.VariantDefinition );

    % ------------- Retrieve Current Parameters ------------- 
        thisActiveSetting.ActiveParametersSet = getActiveParameterValuesFromModelWorkspace( systemname, STOICAL.ParameterDefinition );

    % ------------- Get Active Simulink Model Configuration -------------   
        thisActiveSetting.ActiveSimulinkConfigurationSet = getSimulinkModelConfiguration( systemname );

    % ------------- Get Active SimPowerSystems 2nd Generation Configuration -------------   
        thisActiveSetting.ActiveSimPowerSystemsConfigSet = getSimPowerSystemsV2Configuration( systemname );
        
    % -- ADD Toolboxes etc here --

end

