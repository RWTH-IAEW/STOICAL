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

function [ named_signals ] = setSignalsExplVars2Model( named_signals )
%SETSIGNALSEXPLVARS2MODEL Summary of this function goes here
%   Detailed explanation goes here

    named_signals = stoical.Signals.get.getLogStatus(named_signals);
    
    logsigprefix = getfield(stoical.InternalDataStorage.getVariablePrefixes(),'Signals');
    
    %% Vorschlaege für die LogNamen erarbeiten (max. 63 Zeichen !!!)
    for iSig = 1:named_signals.NrSig
        %Nutze hier die absoluten Pfadangaben und Namen der Signale für
        %eine eindeutige ID 
        uniqueID = [named_signals.ParentalBlockPath{iSig,:} named_signals.NameInDiagram{iSig,:}];
        
        %Nutze einen md5 checksum algorithmus, um injektiv aber nicht
        %notwendiger weite bijektiv eine (relativ) eindeutige ID zu erhalten
        named_signals.NameOfLogVar{iSig,1} = [logsigprefix stoical.General.getmd5(uniqueID)];
    end
    
    %% Signal-Name in Modell-Schreiben (Modell Preparation)
    if named_signals.NrSig > -1
        % bestehenden Logstatus sichern
        savedLogStatus = named_signals.DoLog;
        
        %Namen etc in das Modell schreiben #BUG# / #FEATURE# - request
        named_signals.DoLog(:) = true(named_signals.NrSig,1); % #FAULT# #BUG# TODO Korrektur auf Logical Arrays!
        stoical.Signals.set.setLogStatus(named_signals);
        
        %alten LogStatus wiederherstellen
        named_signals.DoLog = savedLogStatus;
        stoical.Signals.set.setLogStatus(named_signals);
    end
    
end

