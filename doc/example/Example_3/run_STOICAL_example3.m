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

clearvars -except STOICAL_MODEL;
close all;

%% Define Model if not yet defined
    STOICAL_MODEL = 'STOICAL_example_3'

%% ######## Load Simulink and System #####################################
    % load Simulink model into memory, do not open graphical user interface (slower)
    load_system(STOICAL_MODEL)

    % determine where the Simulink model resides
    % only nescessary if we write xyz: 
    % ModelFolder = getsystemlocation( STOICAL_MODEL );

%% ######### Design of Experiments #######################################
    % Define Number of Experiments
    N = 6;

    % input Parameter Values

        % Stimulus (Step)
            parameter_StepAmpl = ones(1,N).*1;

        % Controller 
            structure_controller = {'P-controller','P-controller',...
                                    'PI-controller','PI-controller',...
                                    'PI-controller','PI-controller'};
            
            parameter_P = [0.1000    1.0000    1.0000    2.0000    2.0000    3.0000];
            parameter_I = [nan       nan       1         20        40        55];
            
        % Dynamical System
            % Steady state static system gain
            parameter_SysGain  = ones(1,N).*1;

            %Damping constant of dynamic system (zeta)
            parameter_zeta = ones(1,N).*1.6 + 0;

            %Natural frequency of dynamic system w0 (rad/s)
            parameter_w0 = ones(1,N).*50;
            
    % Timeseries container
        ResponseTimeseries = cell(1,N);
        CtrlOutputTimeseries = cell(1,N);
      
%% ######### Get Data From Model Workspace #############################
    STOICAL = stoical.Aggregations.getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
    
%% ############# LOOP ###################################################

for iRun = 1:N
    
    fprintf('Beginning with Experiment %5i of %5i ...\n',iRun,N);

%% ############# Set Variant Subsystem Active Variants ##################
    % not used here

%% ############# Set Signals to Log  #########################
    % ------------- get actual log-status ------------- 
        STOICAL.SignalDefinition = stoical.Signals.get.getLogStatus(STOICAL.SignalDefinition);

    % ------------- set log status ------------- 
        STOICAL.SignalDefinition.DoLog = ones(size(STOICAL.SignalDefinition.Handle,1),1);
        stoical.Signals.set.setLogStatus( STOICAL.SignalDefinition );
        
%% ############# Set Structure of Model  #########################      

    % ------------- Set all to default strucures first ------------- 
        stoical.VariantSubsystems.interface.setActiveVariants2Default(STOICAL);
        
    % ------------- set some explicitly -------------
        % Controller Type (change structure)
        stoical.VariantSubsystems.interface.setActiveVariant('#Controller',structure_controller{iRun},STOICAL);

%% ############# Set Input Parameters of Model  #########################

    % ------------- Set all to default values first ------------- 
        stoical.Parameters.setParameterValues2Default(STOICAL);
    
    % ------------- set some explicitly ------------- 
        % Stimulus
        stoical.Parameters.setParameterValue('#Stimulus#Amplitude',num2str(parameter_StepAmpl(iRun)),STOICAL);

        % Controller
        stoical.Parameters.setParameterValue('#Controller#P',num2str(parameter_P(iRun)),STOICAL);
        stoical.Parameters.setParameterValue('#Controller#I',num2str(parameter_I(iRun)),STOICAL);

        % System
        stoical.Parameters.setParameterValue('#System#SystemGain',num2str(parameter_SysGain(iRun)),STOICAL);
        stoical.Parameters.setParameterValue('#System#w0',num2str(parameter_w0(iRun)),STOICAL);
        stoical.Parameters.setParameterValue('#System#damp',num2str(parameter_zeta(iRun)),STOICAL);
        
        
        
%% ############# Set Simulink Model Configuration & SimPowerSystems ######

    ConfigurationSetNames = getConfigSets(STOICAL_MODEL);
    setActiveConfigSet(STOICAL_MODEL,ConfigurationSetNames{1});

%% ############# Retrieve Current Configuration and Parametrization ######        
    thisActiveSetting = stoical.Aggregations.getActiveConfigurationAndParameters( STOICAL_MODEL, STOICAL );
    
%% ############# Configure Folders for Building and Caching ####################### 
    stoical.InternalDataStorage.setBuildAndCacheFolder( STOICAL_MODEL, thisActiveSetting );
    
%% ############# Create a unique name for the last simulation ###########
    sim_name = stoical.Aggregations.getSimulationIdentifier( thisActiveSetting, iRun );
        
%% ############# Perform Simulation #########################

    RunInfo{  iRun,1} = struct();
    RunFailed(iRun,1) = false;
        
    try
        %warning('off','all');
        
        %Variant wihtout capturing Output of Simulink
            %eval([STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName ' = sim(system2check);']);
            
        %Variant with capturing output of simulink
            RunMessages{iRun,1} = evalc([STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName ' = sim(STOICAL_MODEL);']);

        %warning('on','all');
    catch exception
        RunFailed(iRun,1) = true;
        disp(' ... FAILED');
        RunInfo{iRun,1}.ExceptionWhileSim = exception;
        RunMessages{iRun,1} = 'See Exception Info';
        
        if isa(exception, 'MSLException')
            % simulink exception -> we have handles to blocks associated
            if ~isempty(exception.handles)
                RunInfo{iRun,1}.ExceptionWhileSimBlockNames = getfullname([exception.handles{:}]);
            end
        else
            % normal matlab exception -> we do not have any handles
        end
    end
    
    RunAcceleratorBuild(iRun,1) = ~isempty(regexp(RunMessages{iRun,1},'### Building the Accelerator target for model','ONCE'));

%% What to do on a failed run
    if RunFailed(iRun,1)
        %next iteration
        continue;
    end
    
%% ############# Retrieve the logged Signals from the Simulink result Object ######
    [ Signal_Stimulus ] = stoical.Signals.get_results.getSignalFromSimulinkOutputObj( '#stimulus', STOICAL );
    [ Signal_Response ] = stoical.Signals.get_results.getSignalFromSimulinkOutputObj( '#response', STOICAL );
    [ Signal_u        ] = stoical.Signals.get_results.getSignalFromSimulinkOutputObj( '#u',        STOICAL );
    
%% temporarily save the signals
    ResponseTimeseries{iRun}   = Signal_Response{1};
    CtrlOutputTimeseries{iRun} = Signal_u{1};
    
%% ############# Direct data processing of signals #########
    % not used here

%% ########## Save configuration to overview file #################
    %not strictly nescessary on direct data processing: 
    % writeActiveSetting2OverviewFile( STOICAL_MODEL, ModelFolder, sim_name, ActiveSetting, STOICAL )
       
end
%  ############# END OF LOOP ###########################################
        
%% Close Simulink Model without saving it
    DoNotSaveChangesFlag = 0; %important !!!
    close_system(STOICAL_MODEL,DoNotSaveChangesFlag);

%% Give Info on Iteration success
    disp(' ');
    fprintf(' %10s | %10s | %10s | %40s\n','Iteration','Success','Acc. Build','Exception Message');
    disp('----------------------------------------------------------------------------------');
    for i = 1:iRun
        if RunFailed(i)
            msg = RunInfo{i}.ExceptionWhileSim.identifier;
        else
            msg = 'none';
        end
        fprintf(' %10i | %10i | %10i | %40s\n',i,~RunFailed(i),RunAcceleratorBuild(i),msg);
    end
        
%% Compare dynamics of close loop controlled system
    figure;
        for iA = 1:2
            
            subplot(1,2,iA);
            
            for ipl = 1:length(ResponseTimeseries)
                switch iA
                    case 1
                        plot(ResponseTimeseries{ipl});
                    case 2
                        plot(CtrlOutputTimeseries{ipl});
                end
                hold all;
            end

            box off

            xlabel('Time [s]');
            
            switch iA
                case 1
                    ylabel('System response [1]');
                case 2
                    ylabel('Controller output [1]');
                    
                    legend(cellfun(@(x,y,z) sprintf('CTRL = %3s, P = %5.1f, I = %5.1f',x,y,z),...
                             strrep(structure_controller','-controller',''),...
                             num2cell(parameter_P'),...
                             num2cell(parameter_I'),'UniformOutput',false),...
                             'Location','SouthEast');
            end

            grid on
            
        end