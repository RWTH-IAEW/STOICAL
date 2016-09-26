% getDefinedLabelRegExp returns regular expression for label definition
%
% Syntax:  [ RegExp_Hierarchy, RegExp_Signals, RegExp_Parameters, RegExp_All, RegExp_DefaultVariant ] = getDefinedLabelRegExp( LabelDefinition )
%
% Inputs:
%    LabelDefinition - struct of label definition
%
% Outputs:
%    RegExp_Hierarchy - regular expression string for hierarchies
%    RegExp_Signals - regular expression string for signals
%    RegExp_Parameters - regular expression string for parameters
%    RegExp_All - regular expression string for all labels
%    RegExp_DefaultVariant - regular expression string for default variants
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    LabelDefinition = getLabelDefinitionFromModelWorkspace( STOICAL_MODEL, 'STOICAL' );
%    [HIRARCHY_RegExp, SIGNAL_RegExp, PARAM_RegExp, RegExp_All, RegExp_DefaultVariant] = ...
%        getDefinedLabelRegExp( LabelDefinition );    
%
% See also: getLabelDefinitionFromModelWorkspace, getJoinedSignals,
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

function [ RegExp_Hierarchy, RegExp_Signals, RegExp_Parameters, RegExp_All, RegExp_DefaultVariant ] ...
    = getDefinedLabelRegExp( LabelDefinition )
    
    fnames   = fieldnames(LabelDefinition);

    if ismember('Hierarchical',fnames)
        RegExp_Hierarchy = strjoin(LabelDefinition.Hierarchical,'|');
    else
        RegExp_Hierarchy = '';
    end
    
    if ismember('Signals',fnames)
        RegExp_Signals = strjoin(LabelDefinition.Signals,'|');
    else
        RegExp_Signals = '';
    end

    if ismember('Parameters',fnames)
        RegExp_Parameters = strjoin(LabelDefinition.Parameters,'|');
    else
        RegExp_Parameters = '';
    end
    
    if ismember('DefaultVariant',fnames)
        RegExp_DefaultVariant = strjoin(LabelDefinition.DefaultVariant,'|');
    else
        RegExp_DefaultVariant = '';
    end
    
    AllLabels = cell(1,0);
    for i=1:size(fnames,1)
        AllLabels = [AllLabels(:);eval(['LabelDefinition.' fnames{i} '(:)'])];
    end
    RegExp_All = strjoin(reshape(AllLabels,1,[]),'|');
    
end

