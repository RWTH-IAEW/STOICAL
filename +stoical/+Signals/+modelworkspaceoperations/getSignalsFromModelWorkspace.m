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

function [ named_signals ] = getSignalsFromModelWorkspace( model_name, topstructurename )
%GETSIGNALSFROMMODELWORKSPACE Summary of this function goes here
%   Detailed explanation goes here
    
%% Get Model Workspace Handle
    hws = get_param(model_name,'ModelWorkspace');
    
%% Get Signals
    % Check if a STOICAL Data Entry exists
    if hws.hasVariable(topstructurename)
        TOPSTRUCT = hws.getVariable(topstructurename);
        
        if isfield(TOPSTRUCT,'SignalDefinition')
            named_signals = TOPSTRUCT.SignalDefinition;
        elseif isfield(TOPSTRUCT,'SourceBlockPort')
            named_signals = TOPSTRUCT;
        else
            named_signals = struct();
            return;    
        end
    else
        named_signals = struct();
        return;
    end
    
    if named_signals.NrSig == 0
        return;
    end
    
%% Update Handles    

    [named_signals.ParentalBlockHandle,hdlsnotfound,named_signals.ParentalBlockPath] = stoical.InternalDataStorage.getUpdatedBlkHandles(named_signals.ParentalBlockPath);
    if any(hdlsnotfound)
        error('STOICAL: Structure of model seems to have changed since model preparation !!');
    end    

    [named_signals.SourceBlockHandle,hdlsnotfound,named_signals.SourceBlockPath] = stoical.InternalDataStorage.getUpdatedBlkHandles(named_signals.SourceBlockPath);
    if any(hdlsnotfound)
        error('STOICAL: Structure of model seems to have changed since model preparation !!');
    end    
    
    % update Handles of lines themselves
    PortHandles = get_param(named_signals.SourceBlockHandle,'PortHandles');
    if ~iscell(PortHandles)
        PortHandles = {PortHandles};
    end
    OutPortHandles = cellfun(@(x,y) x.Outport(y),PortHandles,num2cell(named_signals.SourceBlockPort));
    
    Lines = get_param(OutPortHandles,'Line');
    if ~iscell(Lines)
        Lines = {Lines};
    end
    
    named_signals.Handle = cellfun(@(x) x(1),Lines);
    
end

