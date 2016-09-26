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

function [ NodeIndices, NodeBlkHdls ] = getallVSVariantsByRegExp( RegExp, NodeList )
%GETALLVSVARIANTBYREGEXP Summary of this function goes here
%   Detailed explanation goes here

    if ~any(NodeList.IsVariantSubsystem)
        NodeIndices = [];
        NodeBlkHdls = [];
        return;
    end

        filt_Vars = NodeList.IsVariant;
        Var_Idx = find(filt_Vars);

        % Replace Linebreaks in Variant Names
        NamesVars = NodeList.NodeName(filt_Vars,:);
        %NamesVars = cellfun(@(x) regexprep(x,expression,replace),NamesVars,'UniformOutput',false);
        
        % Replace Whitespace in Variant Names
        %NamesVars = cellfun(@(x) regexprep(x,'\s',''),NamesVars,'UniformOutput',false);
        
        matches2RegExp = regexp(NamesVars,RegExp);

        filt_found = ~cellfun(@isempty,matches2RegExp);

        NodeIndices = Var_Idx(find(filt_found),:);
        NodeBlkHdls = NodeList.NodeHandle(NodeIndices,:);

end

