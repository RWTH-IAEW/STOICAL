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

function [ NodeList ] = setallVSExplVarBasedConditions( NodeList )
%SETALLVSEXPLVARBASEDCONDITIONS Summary of this function goes here
%   Detailed explanation goes here
    
    %% Explizite Variablennamen erarbeiten
    
    VarSysPrefix = getfield(getVariablePrefixes(),'Variants');
    
    % Vorschlag für eindeutige Variablennamen (injektiv, aber nicht
    % bijektiv)s
    path_VS = getfullname(NodeList.NodeHandle);
    if ~iscell(path_VS)
        path_VS = {path_VS};
    end
    
    suggested_namevariable = cellfun(@(x) [VarSysPrefix getmd5(x)],path_VS,'UniformOutput',false);
    
    %Merke die Variablennamen
    NodeList.VSControlVariable = cell(size(NodeList.IsVariantSubsystem,1),1);
    NodeList.VSControlVariable(NodeList.IsVariantSubsystem) = ...
        suggested_namevariable(NodeList.IsVariantSubsystem);
    
    %% Nummern an Varianten vergeben
    
    NodeList.VSVariantHasNr = zeros(size(NodeList.IsVariant,1),1);
    
    for iVSNode = transpose(find(NodeList.IsVariantSubsystem))
        VariantHdls = NodeList.VSVariantsBlkHdls{iVSNode,1};
        
        NrOfVariants = NodeList.VSVariantsCount(iVSNode);
        
        for iVar = 1:NrOfVariants
            varctrlcond = ['' suggested_namevariable{iVSNode,1} ' == ' num2str(iVar) ''];
            %Save conditions into Variants
            set_param(VariantHdls(iVar,1),'VariantControl',varctrlcond);
        end
        
        %Save Idx of Variants
        NodeList.VSVariantHasNr(NodeList.VSVariantsNodeIdx{iVSNode,1},1) = 1:NrOfVariants;
    end
    
    %% delete Override Using Variant of Variant Subsystems
    for iVSNode = transpose(find(NodeList.IsVariantSubsystem))
        %optional:
        %set_param(NodeList.NodeHandle(iVSNode,1),'OverrideUsingVariant','');
    end

end

