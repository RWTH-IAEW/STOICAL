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

function [ NodeList, Edges, A] = getSubsystemGraph( str_model, maxdepth )
%GETLISTNAMEDSIGNALS Summary of this function goes here
%   Detailed explanation goes here

% Prüfe ob System geladen ist
%open_bd = find_system('type', 'block_diagram');
%if ~any(strcmp(open_bd,str_model))
%    load_system(str_model)
%end

% SetzeStartknoten
%NodesToVisit(1,1) = find_system(str_model,'FindAll','on','Type','Block_Diagram');
NodesToVisit(1,1) = get_param(str_model,'Handle');
NodesToVisit(1,2) = 1;
NodesToVisit(1,3) = 1;

% save: NodeHandle NodeName IsVariantSubsystem NodeLevel
NodeList.NodeHandle(1) = get_param(str_model,'Handle');
NodeList.NodeName{1} = str_model;
NodeList.IsVariantSubsystem(1) = isvariantsubsystem(NodeList.NodeHandle(1));
NodeList.NodeLevel(1) = 1;

Edges = [];

while ~isempty(NodesToVisit)
    
    StartHandle = NodesToVisit(1,1);
    StartNode   = NodesToVisit(1,2);
    StartDepth  = NodesToVisit(1,3);
    
    if StartDepth < maxdepth
    
    % Finde alle "Leitungen" in allen Varianten etc.
    [BlockHandles] = find_system(StartHandle,...
        'SearchDepth',1,...
        'FindAll','on',...
        'LookUnderMasks','on',...
        'LoadFullyIfNeeded','on',...
        'Variants','AllVariants',...
        'BlockType','SubSystem'...
        );
    
    filtnoselfref = BlockHandles ~= StartHandle;
    
    BlockHandles = BlockHandles(filtnoselfref,1);
    
    if ~isempty(BlockHandles)

        NrFoundBlocks = size(BlockHandles,1);

        % Ermittle die Namen der "Leitungen"
        Names = get_param(BlockHandles,'Name');
        
        if ~iscell(Names)
            Names = {Names};
        end
        
        %prüfe ob das System ein Variant Subsystem ist
        IsVariantSubs = arrayfun(@(y) isvariantsubsystem(y),BlockHandles);
        
        % save: NodeHandle NodeName IsVariantSubsystem NodeLevel
        NodeList.NodeHandle((end+1):(end+NrFoundBlocks),1) = BlockHandles;
        NodeList.NodeName((end+1):(end+NrFoundBlocks),1) = Names;
        NodeList.IsVariantSubsystem((end+1):(end+NrFoundBlocks),1) = IsVariantSubs;
        NodeList.NodeLevel((end+1):(end+NrFoundBlocks),1) = ones(NrFoundBlocks,1).*(StartDepth+1);

        NodesToVisit((end+1):(end+NrFoundBlocks),1) = BlockHandles;
        NodeNrs = (size(NodeList.NodeHandle,1)-NrFoundBlocks+1):(size(NodeList.NodeHandle,1));
        NodesToVisit((end-NrFoundBlocks+1):(end),2) = NodeNrs;
        NodesToVisit((end-NrFoundBlocks+1):(end),3) = ones(NrFoundBlocks,1).*(StartDepth+1);
        
        % Edges
        
        Edges((end+1):(end+NrFoundBlocks),1) = ones(NrFoundBlocks,1).*StartNode;
        Edges((end-NrFoundBlocks+1):(end),2) = NodeNrs;
    
    end
    
    end
    
    NodesToVisit(1,:) = [];
    
    if size(NodeList.NodeHandle,1) > 10000
        warning('ggf. Endlosschleife? mehr als 10000 Subsysteme gefunden');
        break;
    end
end

NodeList.NodePath = getfullname(NodeList.NodeHandle);
if ~iscell(NodeList.NodePath)
    NodeList.NodePath = {NodeList.NodePath};
end

if ~isempty(Edges)
    A = sparse(Edges(:,1),Edges(:,2),ones(size(Edges,1),1),...
    size(NodeList.NodeHandle,1),size(NodeList.NodeHandle,1));
else
    A = spalloc(size(NodeList.NodeHandle,1),size(NodeList.NodeHandle,1),1);
end

    %prüfe ob das System eine Variante eines Variant Subsystem ist
    ParentNames = get_param(NodeList.NodeHandle,'Parent');
    if ~iscell(ParentNames)
        ParentNames = {ParentNames};
    end
    filt_noparent = cellfun(@isempty,ParentNames);
    IsVariant = ismember(cell2mat(get_param(ParentNames(~filt_noparent),'Handle')),...
                         NodeList.NodeHandle(NodeList.IsVariantSubsystem));
    NodeList.IsVariant(find(~filt_noparent),1) = IsVariant;
    NodeList.IsVariant(filt_noparent,1) = false;

end

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

function [answer] = isvariantsubsystem(x)
    try 
        %test = get_param(x,'ActiveVariant');
        %if ~isempty(test)
        %    answer = true;
        %else
        %    answer = false;
        %end
        test = get_param(x,'Variant');
        ison = strcmp(test,'on');
        if ison
            answer = true;
        else
            answer = false;
        end
    catch
        answer = false;
    end
end

