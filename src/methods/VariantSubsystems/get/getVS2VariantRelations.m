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

function [ NodeList ] = getVS2VariantRelations( NodeList )
%GETVSRELATIONS Summary of this function goes here
%   Detailed explanation goes here

%% Welche Variante gehört zu welchem Variant Subs.?

    ParentNames = get_param(NodeList.NodeHandle,'Parent');
    if ~iscell(ParentNames)
        ParentNames = {ParentNames};
    end
    isemptyParent = cellfun(@isempty,ParentNames);
    
    ParentalNodeHandle(isemptyParent,1) = -1;

    ParentalNodeHandle(~isemptyParent,1) = ...
        cell2mat(get_param(ParentNames(~isemptyParent,1),'Handle'));
    
    [~, posInNodeHdlList] = ismember(ParentalNodeHandle,NodeList.NodeHandle);
    
    VariantOfVSNodeNr = posInNodeHdlList .* NodeList.IsVariant;
    
    NodeList.VSNodeIdxofVariant = VariantOfVSNodeNr;
    
    %clearvars posInNodeHdlList ParentalNodeHandle ParentNames isemptyParent;
    
%% Wie viele Varianten hat jedes Variant Subsystem?
    VSNodeOccurences=unique(VariantOfVSNodeNr);
    VSNodeOccurences(VSNodeOccurences == 0) = [];
    
    [CountVSOccurencesInVariants]=histc(VariantOfVSNodeNr,VSNodeOccurences);
    
    NrOfVariants = zeros(size(NodeList.IsVariantSubsystem,1),1);
    NrOfVariants(VSNodeOccurences) = CountVSOccurencesInVariants;
    
    NodeList.VSVariantsCount = NrOfVariants;
    
    %clearvars CountVSOccurencesInVariants VSNodeOccurences NrOfVariants;
    
%% Liste der Handles der Varianten
    ListOfVarHdls = cell(size(NodeList.IsVariant,1),1);
    NodeList.VSVariantsBlkHdls = cell(size(NodeList.IsVariant,1),1);
    
    ListOfVarIdx = cell(size(NodeList.IsVariant,1),1);
    NodeList.VSVariantsNodeIdx = cell(size(NodeList.IsVariant,1),1);
    
    for iNodeVS = transpose(find(NodeList.IsVariantSubsystem))
        ListOfVarHdls{iNodeVS,1} = NodeList.NodeHandle(VariantOfVSNodeNr == iNodeVS,1);
        ListOfVarIdx{iNodeVS,1} = find(VariantOfVSNodeNr == iNodeVS);
    end
    
    NodeList.VSVariantsBlkHdls = ListOfVarHdls;
    NodeList.VSVariantsNodeIdx = ListOfVarIdx;
    
    %clearvars ListOfVarHdls ListOfVarIdx iNodeVS VariantOfVSNodeNr;
    

end

