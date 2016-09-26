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
open_system(system2load)

%% Get Defined Labels
    [ STOICAL.LabelDefinition, IsDefault ] = getLabelDefinitionFromModelWorkspace( system2load, 'STOICAL' );
    [ HIRARCHY_RegExp, SIGNAL_RegExp, PARAM_RegExp, ALL_RegExp] = ...
        getDefinedLabelRegExp( STOICAL.LabelDefinition );    

%% Finde die pot. Log-Signale
    named_signals = getListSignalsWithRegExpName(system2load,SIGNAL_RegExp);
    
%% Schreibe die Variablen in die Log-Signal Namen    
    named_signals = setSignalsExplVars2Model( named_signals );
    
%% Ermittel labelpath der Signale

    if named_signals.NrSig > 0
        sigpaths = cellfun(@(x,y) [x '/' y],...
                        named_signals.ParentalBlockPath,named_signals.NameInDiagram,...
                        'UniformOutput',false);

        blkpath = sigpaths;%NodeList.NodePath;

        RegExprForSignalLabeling = ['(' HIRARCHY_RegExp ')|(' SIGNAL_RegExp ')'];

        for i = 1:size(blkpath)
            [ labelstring{i,1} ] = path2labelstring( blkpath{i,1}, RegExprForSignalLabeling);
        end
    else
        labelstring = {''};
    end

    named_signals.LabelPath = labelstring;
    

%% Save 2 Model    
    writeSignalsToModelWorkspace( named_signals, system2load, 'STOICAL' );
    
