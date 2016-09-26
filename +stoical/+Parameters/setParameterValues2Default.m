% setParameterValues2Default resets the parameters to the default values
%
% Syntax:  setParameterValues2Default( STOICAL )
%          setParameterValues2Default( STOICAL, 'workspace', 'model' )
%
% Inputs:
%    STOICAL - information about model structure returned by getLabeledObjDataFromModelWorkspace
%              containing information about default values
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    setParameterValues2Default(STOICAL);
%
% See also: setParameterValue, getLabeledObjDataFromModelWorkspace

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

function [ success ] = setParameterValues2Default( STOICAL, varargin )

%% Eingangsparameter SpecialParameters parsen
    p = inputParser;
    %               Name             DefVal   Type
    addParameter(p,'multiple'        ,true    ,@islogical);
    addParameter(p,'workspace'       ,'model'  ,@ischar);
    addParameter(p,'system'          ,bdroot  ,@ischar);
    parse(p,varargin{:});

%%    
    [ var2set, val2set ] = stoical.Parameters.getAllParams2DefaultValues( STOICAL.ParameterDefinition );
    
    switch p.Results.workspace
        case {'model'}
            
            hws = get_param(p.Results.system,'ModelWorkspace');
            
            for ivar = 1:size(var2set,1)
                hws.assignin(var2set{ivar},val2set{ivar});
            end
            
            success = true;
            
        otherwise
            error('not yet implemented');
    end

end

