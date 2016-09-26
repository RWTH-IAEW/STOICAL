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

function [ Prefixes, Suffixes ] = getVariablePrefixes()
%GETVARIABLEPREFIXES Summary of this function goes here
%   Detailed explanation goes here

    %Variable Prefixes for Base or Model-Workspace Control variables
        Prefixes.Signals    = 'logsig_';
        Prefixes.Parameters = 'param_';
        Prefixes.Variants   = 'varsys_cond_';
        
    %Variable Prefixes for Joint Signals
        Prefixes.JoinedSignals = 'joinsig_';

    %Prefixes for Database and File Storage
        Prefixes.VariantSets            = 'varset_';
        Prefixes.ParameterSets          = 'paramset_';
        
        Prefixes.ModelConfigurationSet  = 'modconfset_';
        Prefixes.ModelConfParamsWithoutRebuild = 'modconfOI_';
        Prefixes.SPSConfigurationSet    = 'SPSconfset_';
        
        Prefixes.BuildFolder = 'build_';
        Prefixes.Simulation = 'sim_';
    
    % Suffixes for files and folders
        Suffixes.BuildArchiveFolder = '_builds';

        Suffixes.CatalogueFolder = '_signals'; % unused ? 
        Suffixes.CatalogueFile = '_catalogue';

        Suffixes.OverviewFile  = '_overview';
    

end

