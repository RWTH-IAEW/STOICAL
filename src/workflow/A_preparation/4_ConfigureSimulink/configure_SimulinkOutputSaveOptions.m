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
clearvars -except STOICAL_MODEL testCase;
close all;

system2load = STOICAL_MODEL;

system2check = system2load;

open_system(system2load)

 %% Define the naming parameters for Output Saving
 
    
	% this is the name of the object to create in the workspace, when using
	% the Simulink GUI
    % when using sim() --> outputobjname is determined by the command
    % ????
	outputobjname = 'simout_obj';
	
	% Name of the data logging object inside outputobj (see above)
    logdataobjname = [getToolboxName() '_LoggedSignals'];

    % ??
	%outputsavename = 'youtNew';

 %% Enable and Configure DATA logging and saving

    % Beachten:
    % http://www.mathworks.de/de/help/simulink/ug/using-the-sim-command.html
    %'ReturnWorkspaceOutputs', 'on'
    
    % Set single obj for return behaviour
    set_param(system2check, 'ReturnWorkspaceOutputs', 'on');
    set_param(system2check, 'ReturnWorkspaceOutputsName', outputobjname);

    % Set name of data logging object in single obj for return 
    set_param(system2check, 'SignalLogging', 'on')
    set_param(system2check, 'SignalLoggingSaveFormat', 'Dataset');
    set_param(system2check, 'SignalLoggingName', logdataobjname);
    
    % ?
% 	set_param(system2check, 'SaveOutput','on');
%   set_param(system2check, 'OutputSaveName',outputsavename);
%     

%% Save the configuration to the model workspace for later reuse

    % Get Model Workspace Handle
        hws = get_param(system2load,'ModelWorkspace');
    
    % Retrieve an existing STOICAL variable
        if hws.hasVariable('STOICAL')
            STOICAL =  hws.getVariable('STOICAL');
        end
    
    % Add the Configuration Data
    
            STOICAL.SignalSaveOptions.ReturnWorkspaceOutputs     = 'on';
            STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName = outputobjname;

            STOICAL.SignalSaveOptions.SignalLogging              = 'on';
            STOICAL.SignalSaveOptions.SignalLoggingSaveFormat    = 'Dataset';
            STOICAL.SignalSaveOptions.SignalLoggingName          = logdataobjname;

        % 	STOICAL.SignalSaveOptions.SaveOutput = 'on';
        %   STOICAL.SignalSaveOptions.OutputSaveName = outputsavename;
    
    % Save to Model Workspace
        hws.assignin('STOICAL',STOICAL);

%%        
    warning('SAVE YOUR MODEL !');
