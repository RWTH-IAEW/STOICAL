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

function [ Signals ] = getOutputSignal( outputofsim, logdataobjname, logvarnames )
%GETOUTPUTSIGNALCONTENT Summary of this function goes here
%   Detailed explanation goes here

    % inputdatadef
    %outputofsim = eval(outputobjname);
    
    % support for parfor
    if ischar(outputofsim)
        outputofsim = evalin('base',outputofsim);
    end
    
    % Fallunterscheid output-Typ
    if ~isa(outputofsim,'Simulink.SimulationData.Dataset')

        if isa(outputofsim,'Simulink.SimulationOutput')
            outData = outputofsim.get(logdataobjname);
        else
            error('Nicht implementierter Ausgangsdatentyp');
        end
        
    else
        outData = outputofsim;
    end
    
    if isempty(outData)
        Signals = cell(0,0);
        return;
    end

    
    NrOfLogs = outData.numElements;

    Signals = cell(length(logvarnames),1);
    
    %logidx = reshape(logidx,1,[]);

    for iLS = 1:size(logvarnames)
        
        try
            Signals{iLS,1} = outData.get(logvarnames{iLS}).Values;
        catch
            Signals{iLS,1} = {};
        end

    end
end

