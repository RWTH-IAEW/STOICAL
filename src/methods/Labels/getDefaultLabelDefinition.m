% getDefaultLabelDefinition returns struct of label identifier
%
% Syntax:  [ LabelDefinition ] = getDefaultLabelDefinition()
%
% Outputs:
%    LabelDefinition - struct with default strings for Hierarchical,
%                      Signals,Parameters, DefaultVariant
%
% Example: 
%    LabelDefinition = getDefaultLabelDefinition()
%
% See also: getDefinedLabelRegExp, getJoinedSignals,
% getLabelDefinitionFromModelWorkspace, getPossibleDefinedLabels

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

function [ LabelDefinition ] = getDefaultLabelDefinition()

    LabelDefinition.Hierarchical   = {'#UNIT#'};

    LabelDefinition.Signals        = {'#SIG#'};

    LabelDefinition.Parameters     = {'#PARAM#'};

    LabelDefinition.DefaultVariant = {'#DEF#'};

end

