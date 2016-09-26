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

function [ named_params ] = setDefaultParamFieldEntries( named_params )
%SETDEFAULTPARAMFIELDENTRIES Summary of this function goes here
%   Detailed explanation goes here

    if named_params.NrParams == 0
        named_params.BlkField2Set = {''};
        named_params.BlkFieldSyntax = {''};
        return;
    end

    filt_Gain  = strcmp(named_params.BlkType,'Gain');
    filt_Const = strcmp(named_params.BlkType,'Constant');
    filt_PlainSubsystem = strcmp(named_params.BlkType,'SubSystem') & ...
                          strcmp(named_params.BlkMaskType,''); 

    filt_Other = ~(filt_Gain | filt_Const | filt_PlainSubsystem);
    filt_failed2set = filt_Other;
    
    %get special fields of the subsystems
    specialfields = cell(size(filt_PlainSubsystem,1),1);
    specialfields(filt_PlainSubsystem) = ...
        stoical.General.SpecialSubsystemParameters.getSpecialSubsystemParameters(named_params.BlkHandle(filt_PlainSubsystem));

    Field2Set = cell(size(filt_Gain,1),1);
    Field2Set(filt_Gain,:) = {'Gain'};
    Field2Set(filt_Const,:) = {'Value'};
    for iF = reshape(find(filt_PlainSubsystem),1,[])
        ParamNameInLabel = named_params.ParamName(iF);
        AvailableSpecial = specialfields{iF};
        
        idx = find(ismember(AvailableSpecial,ParamNameInLabel));
        
        if isempty(idx)
            filt_failed2set(iF,1) = true;
        else
            Field2Set(iF,1) = AvailableSpecial(idx);
        end
    end

    Syntax2Set = cell(size(filt_Gain,1),1);
    Syntax2Set(filt_Gain,:) = {'#'};
    Syntax2Set(filt_Const,:) = {'#'};
    Syntax2Set(filt_PlainSubsystem,:) = {'#'};

    named_params.BlkField2Set   = Field2Set;
    named_params.BlkFieldSyntax = Syntax2Set;

end

