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

function [ NodeList ] = getVariantsFromModelWorkspace( model_name, topstructurename, varargin )
%GETSIGNALSFROMMODELWORKSPACE Summary of this function goes here
%   Detailed explanation goes here

%% Parse Input Arguments
    p = inputParser;
    %               Name              Default   Type
    addParameter(p, 'tryUpdatingRelevantOnly'   ,false    ,@islogical);
    parse(p,varargin{:});
    
    updateOnlyRelevant = p.Results.tryUpdatingRelevantOnly;

    
%% Get Model Workspace Handle
    hws = get_param(model_name,'ModelWorkspace');
    
%% Get Signals
    % Check if a STOICAL Data Entry exists
    if hws.hasVariable(topstructurename)
        TOPSTRUCT = hws.getVariable(topstructurename);
        
        if isfield(TOPSTRUCT,'SignalDefinition')
            NodeList = TOPSTRUCT.VariantDefinition;
        elseif isfield(TOPSTRUCT,'IsVariant')
            NodeList = TOPSTRUCT;
        else
            NodeList = struct();
            return;    
        end
    else
        NodeList = struct();
        return;
    end
    
%% Select Handles of Relevance

    if updateOnlyRelevant
        filt_update = NodeList.IsVariantSubsystem | ...
                      NodeList.IsVariant          ...
                      ;
                 
    else
        filt_update = true(size(NodeList.IsVariantSubsystem));
    end
    
%% Update Handles    
%     [NodeList.NodeHandle(filt_update),...
%         hdlsnotfound,NodeList.NodePath(filt_update)] = ...
%             getUpdatedBlkHandlesOfSubsystems(NodeList.NodePath);
    [NodeList.NodeHandle(filt_update,:),...
        hdlsnotfound,NodeList.NodePath(filt_update,:)] = ...
            getUpdatedBlkHandlesOfSubsystems(NodeList.NodePath(filt_update,:));
    if any(hdlsnotfound)
        error('STOICAL: Structure of model seems to have changed since model preparation !!');
    end
    
    % update Variant Handles
    NodeList.VSVariantsBlkHdls = cellfun(@(x) NodeList.NodeHandle(x,:),NodeList.VSVariantsNodeIdx,'UniformOutput',false);
    
end

