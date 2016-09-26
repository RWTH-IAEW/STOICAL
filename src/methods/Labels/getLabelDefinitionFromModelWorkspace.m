% getLabelDefinitionFromModelWorkspace returns LabelDefinition from
% Simulink model
%
% Syntax:  [ LabelDefinition, IsDefault ] = getLabelDefinitionFromModelWorkspace( system2load, NameOfWorkspaceVariable )
%
% Inputs:
%    system2load - simulink model name 
%    NameOfWorkspaceVariable - 
%
% Outputs:
%    LabelDefinition - struct of label definition
%    IsDefault - flag if is default definition
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    [ STOICAL.LabelDefinition, IsDefault ] = getLabelDefinitionFromModelWorkspace( system2load, 'STOICAL' );
%
% See also: getDefinedLabelRegExp, getJoinedSignals,
% getDefaultLabelDefinition, getPossibleDefinedLabels

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

function [ LabelDefinition, IsDefault ] = getLabelDefinitionFromModelWorkspace( system2load, NameOfWorkspaceVariable )

%% Get Defined Labels
    hws = get_param(system2load,'ModelWorkspace');
    
    IsDefault = false;
    
    % Check if a STOICAL Data Entry exists
    if hws.hasVariable(NameOfWorkspaceVariable)
        STOICAL = hws.getVariable(NameOfWorkspaceVariable);
        
        if isfield(STOICAL,'LabelDefinition')
            LabelDefinition = STOICAL.LabelDefinition;
            IsDefault = false;
            return;
        end
        
        fnames   = fieldnames(STOICAL);
        stdnames = fieldnames(getDefaultLabelDefinition());
        testhasfields = ismember(stdnames,fnames);
        
        if any(testhasfields)
            LabelDefinition = STOICAL;
            IsDefault = false;
        else
            IsDefault = true;
        end
    else
        IsDefault = true;
    end
    
    if IsDefault
        warning('No Labels defined in Model Workspace -> taking default');
        LabelDefinition = getDefaultLabelDefinition();
    end

end

