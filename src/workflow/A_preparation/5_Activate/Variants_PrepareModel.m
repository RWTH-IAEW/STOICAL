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
system2check = [system2load]; %/#UNIT#PNB 2/#UNIT#Voltage Controller' '/#UNIT#PNB 1'

%load_system(system2check)
    open_system(system2load);

%Suchtiefe bei Subsystemhierarchie
    searchdepth = Inf;
    
%% Get Defined Labels
    [ STOICAL.LabelDefinition, IsDefault ] = getLabelDefinitionFromModelWorkspace( system2load, 'STOICAL' );
    [ HIRARCHY_RegExp, ~, ~, ~, RegExp_DefaultVariant ] = ...
        getDefinedLabelRegExp( STOICAL.LabelDefinition );
    
%% Ermittle den Graphen der Subsysteme des Modells
[STOICAL.VariantDefinition,Edges,Avoll] = getSubsystemGraph(system2check,searchdepth);

%% Ermittle alle Subsysteme mit einem best. Namen
% listmatchsubsys = getSubsystemsWithRegExpName([system2check],'#UNIT#');
% 
% % Ordne die benannten Subsysteme dem Graphen zu
%     [foundSubs,idxNamedSubsysInGraphNodes] = ismember(listmatchsubsys.Handle,STOICAL.VariantDefinition.NodeHandle);
%     
%     clearvars listmatchsubsys;
        
%% Ermittle die Beziehungen zw. Variant Subsystems und Varianten
    
    STOICAL.VariantDefinition = getVS2VariantRelations(STOICAL.VariantDefinition);
    
%% Lösche alle Active Variant Overrides aus Model
    setallVSOverrideDelete( STOICAL.VariantDefinition );

%% Setze neue explizite Variablen je VS und die entspr. Konditionen

    STOICAL.VariantDefinition = setallVSExplVarBasedConditions( STOICAL.VariantDefinition );
    
%% Determine Default-Variants and activate

    [ STOICAL.VariantDefinition, VSIdxWithoutDef, VSIdxWithOverrideAsDef ] = getallVSDefaultVariant( STOICAL.VariantDefinition, RegExp_DefaultVariant );
    
    if ~isempty(VSIdxWithoutDef)
        warning('Some Variant Subsystems don`t have a Default Variant, set to given override');

            for i = 1:length(VSIdxWithOverrideAsDef)
                labelpath{i,1} = path2labelstring(STOICAL.VariantDefinition.NodePath{VSIdxWithOverrideAsDef(i)},RegExp_All);
            end
            %names = regexprep(STOICAL.VariantDefinition.NodeName(VSIdxWithoutDef),'\n',' ');
        if ~isempty(VSIdxWithOverrideAsDef)
            disp('Variant Subsystems without Default Variant but with given Override:');
    
            names = labelpath;
            fprintf('- %s\n',names{:})        
            
            disp(' ');
        end
        
        warning('Some Variant Subsystems don`t have a Default Variant, set to first found');
        
        disp('Variant Subsystems without Default Variant:');
        
            for i = 1:length(VSIdxWithoutDef)
                labelpath1{i,1} = path2labelstring(STOICAL.VariantDefinition.NodePath{VSIdxWithoutDef(i)},HIRARCHY_RegExp);
            end
            %names = regexprep(STOICAL.VariantDefinition.NodeName(VSIdxWithoutDef),'\n',' ');
            names = labelpath1;
            fprintf('- %s\n',names{:})

    end
    
%% Create Labelpath
    [ HIRARCHY_RegExp, SIGNAL_RegExp, PARAM_RegExp, ALL_RegExp] = ...
        getDefinedLabelRegExp( STOICAL.LabelDefinition );

    STOICAL.VariantDefinition.LabelPath = cell(size(STOICAL.VariantDefinition.IsVariant));

    STOICAL.VariantDefinition.LabelPath(STOICAL.VariantDefinition.IsVariantSubsystem) = ...
        cellfun(@(x) path2labelstring(x,HIRARCHY_RegExp), ...
        STOICAL.VariantDefinition.NodePath(STOICAL.VariantDefinition.IsVariantSubsystem),...
        'UniformOutput',false);
    
%% Write 2 Modell

    writeVariantsToModelWorkspace(STOICAL.VariantDefinition,system2load,'STOICAL');
    