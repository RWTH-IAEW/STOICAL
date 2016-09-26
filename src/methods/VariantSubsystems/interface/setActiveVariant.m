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

function [ success ] = setActiveVariant( varsubsys_labelpath_regexp, variant_regexp, STOICAL, varargin )
%SETACTIVEVARIANT Summary of this function goes here
%   Detailed explanation goes here

%% Eingangsparameter SpecialParameters parsen
    p = inputParser;
    %               Name             DefVal   Type
    addParameter(p,'multiple'        ,true    ,@islogical);
    addParameter(p,'workspace'       ,'base'  ,@ischar);
    parse(p,varargin{:});
    
%%    

    % Finde die zu setzenden VS über die Label-Adressierung
    filt = STOICAL.VariantDefinition.IsVariantSubsystem;
    [~, VShdl2set] = l2p(varsubsys_labelpath_regexp,...
                         STOICAL.VariantDefinition.NodeHandle(filt,:),...
                         'multiple', p.Results.multiple);
                     
    % Setze die Variablen
    for VShdl = reshape(VShdl2set,1,[])
        [ var2set, value2set ] = getVSExplVarSettingforVariant( VShdl, variant_regexp, STOICAL.VariantDefinition, ' ' );
        evalin(p.Results.workspace,...
               [var2set ' = ' num2str(value2set) ';']);
    end

%%    
    if ~isempty(VShdl2set)
        success = true;
    else
        success = false;
    end
end

