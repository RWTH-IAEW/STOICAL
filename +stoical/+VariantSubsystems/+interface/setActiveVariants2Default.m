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

function [ success ] = setActiveVariants2Default( STOICAL, varargin )
%SETACTIVEVARIANT Summary of this function goes here
%   Detailed explanation goes here

%% Eingangsparameter SpecialParameters parsen
    p = inputParser;
    %               Name             DefVal   Type
    %addParameter(p,'multiple'        ,true    ,@islogical);
    addParameter(p,'workspace'       ,'base'  ,@ischar);
    parse(p,varargin{:});
    
%%    

    [ vars2set, values2set ] = stoical.VariantSubsystems.get.getallVSExplVarSettingForDefaultVariant( STOICAL.VariantDefinition );
    for ivar = 1:size(vars2set,1)
        evalin(p.Results.workspace,[vars2set{ivar,1} ' = ' num2str(values2set(ivar,1)) ';']);
    end

%%    
    if ~isempty(vars2set)
        success = true;
    else
        success = false;
    end
end

