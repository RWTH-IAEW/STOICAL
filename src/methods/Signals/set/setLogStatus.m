% setLogStatus sets the log status for signals defined in the STOICAL model
%
% Syntax:  setLogStatus( SignalDefinition )
%
% Inputs:
%    SignalDefinition - struct containing signal information
%
% Example: 
%    STOICAL_MODEL = 'STOICAL_example_1'
%    STOICAL = getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
%    STOICAL.SignalDefinition = getLogStatus(STOICAL.SignalDefinition);
%    %% logging all signals
%    STOICAL.SignalDefinition.DoLog = ones(size(STOICAL.SignalDefinition.Handle,1),1);
%    setLogStatus( STOICAL.SignalDefinition );
%
% See also: getLogStatus

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

function setLogStatus( SignalDefinition )

    for irow = 1:size(SignalDefinition.DoLog,1)
        idx = irow;

        test = get_param(SignalDefinition.SourceBlockPath{idx,1},'PortHandles');
        
        sigPortHdl = test.Outport(SignalDefinition.SourceBlockPort(idx,1));

        if SignalDefinition.DoLog(idx,1) == false
            %do delete the logging
            set_param(sigPortHdl,'DataLogging','off')
        end

        if SignalDefinition.DoLog(idx,1) ~= false
            set_param(sigPortHdl,'DataLogging','on')
            set_param(sigPortHdl,'DataLoggingNameMode','Custom');
            set_param(sigPortHdl,'DataLoggingName',SignalDefinition.NameOfLogVar{idx,1});
        end
    end

end

