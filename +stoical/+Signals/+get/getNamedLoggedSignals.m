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

function [ named_signals ] = getNamedLoggedSignals( str_model )
%GETLISTNAMEDSIGNALS Summary of this function goes here
%   Detailed explanation goes here

% Prüfe ob System geladen ist
% open_bd = find_system('type', 'block_diagram');
% if ~any(strcmp(open_bd,str_model))
%     load_system(str_model)
% end

% Finde alle geloggtenSignale in allen Varianten etc.
[BlockPaths1] = find_system(str_model,...
    'FindAll','on',...
    'LookUnderMasks','on',...
    'LoadFullyIfNeeded','on',...
    'Variants','AllVariants',...
    'Type','port',...
    'DataLogging','on'...
    );

PathLoggedSignalObjs = getfullname(BlockPaths1);

% Finde alle "Leitungen" in allen Varianten etc.
[BlockPaths2] = find_system(str_model,...
    'FindAll','on',...
    'LookUnderMasks','on',...
    'LoadFullyIfNeeded','on',...
    'Variants','AllVariants',...
    'Type','Line'...
    );

% Ermittle die Namen der "Leitungen"
Names = get_param(BlockPaths2,'Name');

% Ermittle einen Filter für die unbenannten Signale
filt_signals_with_names = ~cellfun(@isempty,Names);

% Erste Filterstufe: nur unbenannten Signale / Leitungen übrig lassen
NamesOfNamedSignals = Names(filt_signals_with_names);
BlockPathReal = getfullname(BlockPaths2(filt_signals_with_names));
HandlesOfNamesSignals = BlockPaths2(filt_signals_with_names);

% Eliminiere Leitungsverzweigungen mit gemeinsamem Ursprungsknoten und Port
% (mehr als 1 mal kann man nicht Loggen)
[~,idx_unique] = unique(BlockPathReal);

% Zweite Filterstufe: Eliminiere alle Leitungsverzweigungen
SignalNamesOnce    = NamesOfNamedSignals(idx_unique,:);
StartBlockPathOnce = BlockPathReal(idx_unique,:);
HandlesOnce        = HandlesOfNamesSignals(idx_unique,:);
%Eltern-Block-Pfad ermitteln
ParentBlocksOfSignals = get_param(HandlesOnce,'Parent');

% Separiere Startblock und Port-Nr des Startblocks der Leitung
for iSign = 1:size(SignalNamesOnce,1)
    [ StartingBlockOnce{iSign,1},PortNrOnce{iSign,1},~ ] = fileparts(StartBlockPathOnce{iSign,:});
end
% Erzeuge Cellarray der Start-Port-Nrn
PortNrs = cellfun(@str2num,PortNrOnce,'UniformOutput',false);

% Ermittle welche hiervon ein Logging haben

idxLinelogbutnosig = [];

for iLogSig = 1:size(PathLoggedSignalObjs,1)
    name = PathLoggedSignalObjs{iLogSig,1};
    if strcmp(name(end),'/')
        name = name(1:(end-1));
    end
    idxLinelogbutnosig = [idxLinelogbutnosig;find(strcmp(name,StartingBlockOnce))];
end

% Erzeuge ein Ergebnis-Struct
named_signals = struct();

named_signals.ParentalBlockPath = ParentBlocksOfSignals(idxLinelogbutnosig);
%unnamed_signals.NameInDiagram     = SignalNamesOnce;
named_signals.SourceBlockPath   = StartingBlockOnce(idxLinelogbutnosig);
named_signals.SourceBlockPort   = PortNrs(idxLinelogbutnosig);
named_signals.Handle            = HandlesOnce(idxLinelogbutnosig);

end

