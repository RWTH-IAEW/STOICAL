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

function [ named_params ] = getParametersFromModelWorkspace( model_name, topstructurename, varargin)
%GETSIGNALSFROMMODELWORKSPACE Summary of this function goes here
%   Detailed explanation goes here

%% Parse Input Arguments
    p = inputParser;
    %               Name              Default   Type
    addParameter(p, 'ignoreUnfound'   ,false    ,@islogical);
    parse(p,varargin{:});
    
    ignoreThoseNotFound = p.Results.ignoreUnfound;
    
%% Get Model Workspace Handle
    hws = get_param(model_name,'ModelWorkspace');
    
%% Get Signals
    % Check if a STOICAL Data Entry exists
    if hws.hasVariable(topstructurename)
        TOPSTRUCT = hws.getVariable(topstructurename);
        
        if isfield(TOPSTRUCT,'SignalDefinition')
            named_params = TOPSTRUCT.ParameterDefinition;
        elseif isfield(TOPSTRUCT,'Belongs2SubsystemHdl')
            named_params = TOPSTRUCT;
        else
            named_params = struct();
            return;    
        end
    else
        named_params = struct();
        return;
    end
    
    if named_params.NrParams == 0
        return;
    end
    
%% Update Handles    
    [named_params.ParentalBlockHandle,hdlsnotfound,named_params.ParentalBlockPath] = getUpdatedBlkHandles(named_params.ParentalBlockPath);
    if ~ignoreThoseNotFound && any(hdlsnotfound)
        error('STOICAL: Structure of model seems to have changed since model preparation !!');
    end    

    [named_params.BlkHandle,hdlsnotfound,named_params.BlkPath] = getUpdatedBlkHandles(named_params.BlkPath);
    if ~ignoreThoseNotFound && any(hdlsnotfound)
        error('STOICAL: Structure of model seems to have changed since model preparation !!');
    end    
    
    % update Belonging
    filt_issubsys = ismember(named_params.BlkType,{'SubSystem'});
    named_params.Belongs2SubsystemHdl = named_params.ParentalBlockHandle;
    named_params.Belongs2SubsystemHdl(filt_issubsys,:) = named_params.BlkHandle(filt_issubsys,:);
    
end

