% getLogStatus retrieves the log status of signals defined in the STOICAL
% model
%
% Syntax:  [ SignalDefinition ] = getLogStatus( SignalDefinition )
%
% Inputs:
%    SignalDefinition - struct of signal information retrieved by getLabeledObjDataFromModelWorkspace
%
% Outputs:
%    SignalDefinition - extended by cells NameOfLogVar, NameOfLogVarMode and binary flag DoLog
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    STOICAL.SignalDefinition = getLogStatus(STOICAL.SignalDefinition);
%
% See also: setLogStatus, getLabeledObjDataFromModelWorkspace

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

function [ SignalDefinition ] = getLogStatus( SignalDefinition )

s2c = SignalDefinition;

if SignalDefinition.NrSig > 0

    for idx = 1:size(s2c.NameInDiagram,1)    

        test = get_param(s2c.SourceBlockPath{idx,1},'PortHandles');

        PortHandle = test.Outport(s2c.SourceBlockPort(idx,1));

        IsLogged_str{idx,1}        = get_param(PortHandle,'DataLogging');
        LoggedNameMode_str{idx,1}  = get_param(PortHandle,'DataLoggingNameMode');
        LoggedName_str{idx,1}      = get_param(PortHandle,'DataLoggingName');

    end
    
    dologflag = strcmp(IsLogged_str,'on');
    
else
    LoggedNameMode_str = cell(0,1);
    LoggedName_str     = cell(0,1);
    dologflag          = false(0,1);
end


SignalDefinition.NameOfLogVar      = LoggedName_str;
SignalDefinition.NameOfLogVarMode  = LoggedNameMode_str;
SignalDefinition.DoLog             = dologflag;

end

