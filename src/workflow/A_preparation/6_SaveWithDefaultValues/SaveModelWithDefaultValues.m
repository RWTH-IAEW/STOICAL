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

%% ######## Load Simulink and System #####################################

    load_system(STOICAL_MODEL)
    
%% ######### Get Data From Model Workspace #############################
    
    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);

    [ HIRARCHY_RegExp, SIGNAL_RegExp, PARAM_RegExp, RegExp_All, RegExp_DefaultVariant ] = ...
       getDefinedLabelRegExp( STOICAL.LabelDefinition );
    
%% ############# LOOP ###################################################

for iRun = 1:1
    
    pretimetic = tic;

%% ############# Set Variant Subsystem Active Variants ##################

    %% Set all VS to their defined or assumed defaults
        [ vars2set, values2set ] = getallVSExplVarSettingForDefaultVariant( STOICAL.VariantDefinition );
        for ivar = 1:size(vars2set,1)
            eval([vars2set{ivar,1} ' = ' num2str(values2set(ivar,1)) ';']);
        end

%% ############# Set Signals to Log  #########################
    %% get actual log-status
        STOICAL.SignalDefinition = getLogStatus(STOICAL.SignalDefinition);

    %% set log status
        STOICAL.SignalDefinition.DoLog = ones(size(STOICAL.SignalDefinition.Handle,1),1);
        setLogStatus( STOICAL.SignalDefinition );

%% ############# Set Input Parameters of Model  #########################

    % Get Model Workspace handle
        hws = get_param(STOICAL_MODEL,'ModelWorkspace');

    %% Set all to default values first
        [ var2set, val2set ] = getAllParams2DefaultValues( STOICAL.ParameterDefinition );
        for ivar = 1:size(var2set,1)
            hws.assignin(var2set{ivar},val2set{ivar});
        end
        
%% ############# Set Simulink Model Configuration & SimPowerSystems ######

    % Simulink
        ConfigurationSetNames = getConfigSets(STOICAL_MODEL);
        ActiveConfigSetNr = 1;

        setActiveConfigSet(STOICAL_MODEL,ConfigurationSetNames{ActiveConfigSetNr});
        
%% ############# Retrieve Current Parameters ####################### 
%     ActiveValueSet = ...
%         getActiveParameterValuesFromModelWorkspace( STOICAL_MODEL, STOICAL.ParameterDefinition );

%% ############# Cleanup #######################
    % Delete Variables from Base Workspace
        VPref =getVariablePrefixes();
        FilterRegExp = [VPref.Signals '.*|' VPref.Parameters '.*|' VPref.Variants];
        eval(['clearvars -regexp ' FilterRegExp]);
            
end
%  ############# END OF LOOP ###########################################
        
    save_system(STOICAL_MODEL);

%% ############# Cleanup #######################
    DoNotSaveChangesFlag = 0;    
    close_system(STOICAL_MODEL,DoNotSaveChangesFlag);
    
% %% ######## Disconnect Database ###########
%     close(Db);