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
    STOICAL_MODEL = 'STOICAL_example_2'

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
            %parameter_StepAmpl = rand(1,N).*3 + 0.1;
            parameter_StepAmpl = ones(1,N).*1 + 0;

        % Dynamical System
            %parameter_SysGain  = rand(1,N).*2 + 0.1;
            parameter_SysGain  = ones(1,N).*1 + 0;

            %Damping constant of dynamic system (zeta)
            parameter_zeta = [0.2 0.4 1/sqrt(2) 1 1.3 2];

            %Natural frequency of dynamic system w0 (rad/s)
            parameter_w0 = ones(1,N).*50;

    % Timeseries container
    ResponseTimeseries = cell(1,N);
      
%% ######### Get Data From Model Workspace #############################
    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
    
%% ############# LOOP ###################################################

for iRun = 1:N
    
    fprintf('Beginning with Experiment %5i of %5i ...\n',iRun,N);

%% ############# Set Variant Subsystem Active Variants ##################
    % not used here

%% ############# Set Signals to Log  #########################
    % ------------- get actual log-status ------------- 
        STOICAL.SignalDefinition = getLogStatus(STOICAL.SignalDefinition);

    % ------------- set log status ------------- 
        STOICAL.SignalDefinition.DoLog = ones(size(STOICAL.SignalDefinition.Handle,1),1);
        setLogStatus( STOICAL.SignalDefinition );

%% ############# Set Input Parameters of Model  #########################

    % ------------- Set all to default values first ------------- 
        setParameterValues2Default(STOICAL);
    
    % ------------- set some explicitly ------------- 
        setParameterValue('#Stimulus#Amplitude',num2str(parameter_StepAmpl(iRun)),STOICAL);

        setParameterValue('#System#SystemGain',num2str(parameter_SysGain(iRun)),STOICAL);
        
        setParameterValue('#System#w0',num2str(parameter_w0(iRun)),STOICAL);

        setParameterValue('#System#damp',num2str(parameter_zeta(iRun)),STOICAL);
        
        
%% ############# Set Simulink Model Configuration & SimPowerSystems ######

    ConfigurationSetNames = getConfigSets(STOICAL_MODEL);
    setActiveConfigSet(STOICAL_MODEL,ConfigurationSetNames{1});

%% ############# Retrieve Current Configuration and Parametrization ######        
    thisActiveSetting = getActiveConfigurationAndParameters( STOICAL_MODEL, STOICAL );
    
%% ############# Configure Folders for Building and Caching ####################### 
    setBuildAndCacheFolder( STOICAL_MODEL, thisActiveSetting );
    
%% ############# Create a unique name for the last simulation ###########
    sim_name = getSimulationIdentifier( thisActiveSetting, iRun );
        
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
    [ Signal_Stimulus ] = getSignalFromSimulinkOutputObj( '#stimulus', STOICAL );
    [ Signal_Response ] = getSignalFromSimulinkOutputObj( '#response', STOICAL );
    
    % temporarily save the signals
    ResponseTimeseries{iRun} = Signal_Response{1};
    
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
        
%% Compare dynamics
    figure;
        for ipl = 1:length(ResponseTimeseries)
            plot(ResponseTimeseries{ipl})
            hold all;
        end
        
        box off
        legend(cellfun(@(x) ['\zeta = ' num2str(x)],num2cell(parameter_zeta'),'UniformOutput',false))
        
        xlabel('Time [s]');
        ylabel('System response [1]');
        
        grid on