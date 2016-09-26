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

function [ LogVarNames2get, Names, LabelPath ] = getAllSignalNamesForLabel( SignalLabelRegExp, SignalDefinition, LogNamesFound)
%GETOUTPUTBYLABELS Summary of this function goes here
%   Detailed explanation goes here

    % Erstelle ein Mapping der im Result-Object gefundenen Logs auf den
    % Index der SignalDefinition Liste
    [~,ia,ib] = intersect(SignalDefinition.NameOfLogVar,LogNamesFound);
    MappingLogged2List(ib,1) = ia;

    % Welches LabelPath haben die geloggten im Result-Object?
    LabelPathOfLogged = SignalDefinition.LabelPath(MappingLogged2List,:);

    % Welche davon will der Nutzer haben?
    idx2getOfLogged = ...
        find(~cellfun(@isempty,regexp(LabelPathOfLogged,SignalLabelRegExp)));

    % Welche Variablennamen müssen gewonnen werden?
    LogVarNames2get = LogNamesFound(idx2getOfLogged);

    % Hohle die Signale und gebe zurück
    %Signals = getOutputSignal( outputobj, logdataobjname, logvarnames2get);

    % Gebe Infos zurück über die gehohlten Signale
    Names     = SignalDefinition.NameInDiagram(MappingLogged2List(idx2getOfLogged));
    LabelPath = SignalDefinition.LabelPath(    MappingLogged2List(idx2getOfLogged));

end

