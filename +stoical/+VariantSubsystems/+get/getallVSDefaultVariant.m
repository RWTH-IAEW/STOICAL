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

function [ NodeList, VSIdxWithoutDef, VSIdxWithOverrideAsDef ] = getallVSDefaultVariant( NodeList, DefaultMarkerInVariantName )
%GETALLVSDEFAULTVARIANT Summary of this function goes here
%   Detailed explanation goes here

    if ~any(NodeList.IsVariantSubsystem)
        VSIdxWithoutDef = [];
        VSIdxWithOverrideAsDef = [];
        return;
    end

    [ NodeIndices, NodeBlkHdls ] = stoical.VariantSubsystems.get.getallVSVariantsByRegExp(DefaultMarkerInVariantName,NodeList);

    % set fla for the default variant found
    NodeList.IsDefaultVariant = false(size(NodeList.IsVariant,1),1);
    NodeList.IsDefaultVariant(NodeIndices,:) = true;
    
    %project to Variant Subsystems
    NodeList.VSDefaultVariantNr = ones(size(NodeList.IsVariant,1),1) .* -1 .* NodeList.IsVariantSubsystem;
    ParentVSIdx = NodeList.VSNodeIdxofVariant(NodeIndices,:);
    NodeList.VSDefaultVariantNr(ParentVSIdx,:) = NodeList.VSVariantHasNr(NodeIndices);

    %What to set if there is no #DEF# Variant?
    filt_nodef = NodeList.VSDefaultVariantNr == -1;
    
% SOME PROBLEMS INVOLVED HERE: variant control is not generated !
%     % test if there are overrides active for the other variants
%         IsVariantOverrideActive = getVSOverrideVariantStatus( NodeList );
% 
%         filt_withoutdef_but_withoverride = filt_nodef & IsVariantOverrideActive;
% 
%         idxoverriden = find(filt_withoutdef_but_withoverride);
%         [OverridenVariantNr,hasValidActiveVariant] = getVSactiveVariant( idxoverriden, NodeList );
%         idx_valid = idxoverriden(hasValidActiveVariant);
%         idx_invalid = idxoverriden(~hasValidActiveVariant);
%         
%         NodeList.VSDefaultVariantNr(idx_valid) = OverridenVariantNr(hasValidActiveVariant);
%         
%         for i = 1:length(idx_valid)
%             %NodeList.IsDefaultVariant()
%             NodeIndices = NodeList.VSVariantsNodeIdx{idx_valid(i)};
%             NodeList.IsDefaultVariant(NodeIndices(OverridenVariantNr(i))) = true;
%         end
%         
%         filt_withoutdef_but_withoverride(idx_invalid) = false;
%         
%         filt_nodef = filt_nodef & ~filt_withoutdef_but_withoverride;
%         
%         VSIdxWithOverrideAsDef = find(filt_withoutdef_but_withoverride);
VSIdxWithOverrideAsDef = [];

    % the rest ...
    NodeList.VSDefaultVariantNr(filt_nodef,:) = 1;
    
    VSIdxWithoutDef = find(filt_nodef);

    %do set the def. variant flag for the last ones too
    FirstVarIdx = cellfun(@(x) x(1),NodeList.VSVariantsNodeIdx(filt_nodef,:));
    NodeList.IsDefaultVariant(FirstVarIdx,1) = true;

end

