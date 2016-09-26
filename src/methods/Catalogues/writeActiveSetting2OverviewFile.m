% writeActiveSetting2OverviewFile - 
%
% Syntax:  writeActiveSetting2OverviewFile( systemname, folder2use, SimulationIdentifier, ActiveSetting, STOICAL )
%
% Inputs:
%    systemname - 
%    folder2use - 
%    SimulationIdentifier - 
%    ActiveSetting - 
%    STOICAL - 
%
% Example: 
%
%
% See also: getActiveVariantsFromCatalogue,
% getSignalSimulationsMapFromCatalogue, writeActiveSetting2OverviewFile, loadCatalogue
%

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

function [] = writeActiveSetting2OverviewFile( systemname, folder2use, SimulationIdentifier, ActiveSetting, STOICAL )

%% Get Pre- and Suffixes
    [ ~, Suffixes ] = getVariablePrefixes();

%% Save to overview file    
        % Save Information in Simulation Container
            eval([SimulationIdentifier ' = ActiveSetting;']);
        
        % Define Overview Filename
            overviewfilename = [folder2use filesep() ...
                   systemname Suffixes.OverviewFile];
        
        % Create File and Save Frist or Append 
        if exist([overviewfilename '.mat'],'file') == 2
            save(overviewfilename,SimulationIdentifier,'-append','-v6');
        else
            % Frist time of saving
            save(overviewfilename,SimulationIdentifier,'STOICAL','-v6');
        end


end

