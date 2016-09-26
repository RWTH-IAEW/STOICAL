% setBuildAndCacheFolder sets folder for building of accelerator models to
% a unique folder name
%
% Syntax:  setBuildAndCacheFolder( systemname, ActiveSetting )
%
% Inputs:
%    systemname - simulink model name 
%    ActiveSetting - struct of current active setting
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    thisActiveSetting = getActiveConfigurationAndParameters( STOICAL_MODEL, STOICAL );
%    setBuildAndCacheFolder( STOICAL_MODEL, thisActiveSetting );
%
% See also: getActiveConfigurationAndParameters

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

function [] = setBuildAndCacheFolder( systemname, ActiveSetting )

%% Get Naming conventions for files, folders and data structures
    [ Prefixes, Suffixes ] = getVariablePrefixes();

%%    
    %Create path
        MODEL_folder = getsystemlocation(systemname);    
        % superfolder of archive in the same directory as 
            topfolder = [systemname Suffixes.BuildArchiveFolder];
        % subfolder (all infos combined due to path length restrictions)
            combofolder = [Prefixes.BuildFolder getmd5([...
                                         ActiveSetting.ActiveVariantSet.AllEntriesValueString.BuildRelevant ...
                                         ActiveSetting.ActiveParametersSet.AllEntriesValueString.BuildRelevant ...
                                         ActiveSetting.ActiveSimulinkConfigurationSet.AllEntriesValueString.BuildRelevant ...
                                         ActiveSetting.ActiveSimPowerSystemsConfigSet.AllEntriesValueString.BuildRelevant])];
        % absolute folder
            fullnewpath = [MODEL_folder filesep topfolder filesep combofolder];

    %set path for cache and code generation
        warning('off','MATLAB:dispatcher:nameConflict');
        Simulink.fileGenControl('set','CacheFolder',fullnewpath,'CodeGenFolder',fullnewpath,'createDir',true);%'keepPreviousPath',false,
        warning('on','MATLAB:dispatcher:nameConflict');

end

