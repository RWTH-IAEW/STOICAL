% setParameterValue set the parameter value of the specified parameter to the
% specified value in STOICAL model
%
% Syntax:  setParameterValues( param_labelstring, value, STOICAL )
%
% Inputs:
%    param_labelstring - identifier of parameter
%    value - value to set
%    STOICAL - information about model structure returned by getLabeledObjDataFromModelWorkspace
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    setParameterValue('#Stimulus#Amplitude', num2str(5), STOICAL);
%
% See also: setParameterValues2Default

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

function [ success ] = setParameterValue( param_labelstring, value, STOICAL, varargin )

%% Eingangsparameter SpecialParameters parsen
    p = inputParser;
    %               Name             DefVal   Type
    addParameter(p,'multiple'        ,true    ,@islogical);
    addParameter(p,'workspace'       ,'model'  ,@ischar);
    addParameter(p,'system'          ,bdroot  ,@ischar);
    parse(p,varargin{:});
    
%% convert format
    if isnumeric(value)
        value = sprintf('%0.20f',value);
    end

%%    
    var2set = getParamVariable2Set(param_labelstring,STOICAL.ParameterDefinition,'multiple',p.Results.multiple);
    
    switch p.Results.workspace
        case {'model'}
            
            hws = get_param(p.Results.system,'ModelWorkspace');
            
            for ivar = 1:size(var2set,1)
                hws.assignin(var2set{ivar},value);
            end
            
            success = true;
            
        otherwise
            error('not yet implemented');
    end

end

