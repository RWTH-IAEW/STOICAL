% loadCatalogue - 
%
% Syntax:  [ Overview, STOICAL ] = loadCatalogue( systemname, fileabspathname )
%
% Inputs:
%    systemname - 
%    fileabspathname - 
%
% Outputs:
%    Overview - 
%    STOICAL - 
%
% Example: 
%
%
% See also: getActiveParametersFromCatalogue, getActiveVariantsFromCatalogue,
% getSignalSimulationsMapFromCatalogue, writeActiveSetting2OverviewFile
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

function [ Overview, STOICAL ] = loadCatalogue( systemname, fileabspathname )

    if nargin < 2
        [ ~, Suffixes ] = getVariablePrefixes();
        
        MODEL_folder = getsystemlocation(systemname);
        
        CONST_CatalogueFile = [MODEL_folder filesep [systemname Suffixes.CatalogueFile '.mat']];
    else
        CONST_CatalogueFile = fileabspathname;
    end

    data = load(CONST_CatalogueFile); %contains: Overview + STOICAL

    STOICAL = data.STOICAL;
    Overview = data.Overview;
end

