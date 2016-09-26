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

clc;
clearvars -except STOICAL_MODEL;
close all;

system2load = STOICAL_MODEL;
system2check = [system2load];

open_system(system2check);

%% Get Model Workspace Handle
    hws = get_param(system2load,'ModelWorkspace');
    
    if hws.hasVariable('STOICAL')
        STOICAL =  hws.getVariable('STOICAL');
    end
    
%% Get Definition From File or else take Default Labels
    [ STOICAL.LabelDefinition, IsDefault ] = getLabelDefinitionFromModelWorkspace( system2load, 'STOICAL' );

%% Change Label Definition

% Change Definition
    % STOICAL.LabelDefinition.Hierarchical   = {'#UNIT#','#MODULE#'};
    % STOICAL.LabelDefinition.Signals        = {'#SIG#'};
    % STOICAL.LabelDefinition.Parameters     = {'#PARAM#'};
    % STOICAL.LabelDefinition.DefaultVariant = {'#DEF#'};

%% Save to Model Workspace

hws.assignin('STOICAL',STOICAL);

warning('SAVE YOUR MODEL !');