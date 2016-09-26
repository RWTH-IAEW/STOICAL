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

function [ named_signals ] = getListSignalsWithRegExpName( str_model, RegExpName )
%GETLISTNAMEDSIGNALS Summary of this function goes here
%   Detailed explanation goes here

% Prüfe ob System geladen ist
% open_bd = find_system('type', 'block_diagram');
% if ~any(strcmp(open_bd,str_model))
%     load_system(str_model)
% end

% Finde alle "Leitungen" in allen Varianten etc.
[BlockPaths2] = find_system(str_model,...
    'FindAll','on',...
    'LookUnderMasks','on',...
    'LoadFullyIfNeeded','on',...
    'RegExp','on',...
    'Variants','AllVariants',...
    'Type','Line',...
    'Name',RegExpName...
    );

% Ermittle die Namen der "Leitungen"
Names = get_param(BlockPaths2,'Name');
if ~iscell(Names)
    Names = {Names};
end

% Zweite Filterstufe: Eliminiere alle Leitungsverzweigungen
BlockPathReal = getfullname(BlockPaths2);
if ~iscell(BlockPathReal)
    BlockPathReal = {BlockPathReal};
end
[~,idx_unique] = unique(BlockPathReal);

SignalNamesOnce    = Names(idx_unique,:);
StartBlockPathOnce = BlockPathReal(idx_unique,:);
HandlesOnce        = BlockPaths2(idx_unique,:);

% Erste Filterstufe: nur benannten Signale / Leitungen übrig lassen
NamesOfNamedSignals   = SignalNamesOnce;

if ~iscell(StartBlockPathOnce)
    StartBlockPathOnce = {StartBlockPathOnce};
end

% Separiere Startblock und Port-Nr des Startblocks der Leitung
for iSign = 1:size(SignalNamesOnce,1)
    [ StartingBlockOnce{iSign,1},PortNrOnce{iSign,1},~ ] = fileparts(StartBlockPathOnce{iSign,:});
end
% Erzeuge Cellarray der Start-Port-Nrn
%PortNrs = cellfun(@str2num,PortNrOnce,'UniformOutput',false);

if isempty(BlockPaths2)
    PortNrs = {};
    ParentBlocksOfSignals = {''};
    ParentBlockHdl = {};
    StartingBlockOnce = {''};
    SourceHdl = {};
    NrSig = 0;
else
    PortNrs = cellfun(@str2num,PortNrOnce);
    %Eltern-Block-Pfad ermitteln
    ParentBlocksOfSignals = get_param(StartingBlockOnce,'Parent');
    ParentBlockHdl = cell2mat(get_param(ParentBlocksOfSignals,'Handle'));
    SourceHdl = cell2mat(get_param(StartingBlockOnce,'Handle'));
    NrSig = size(PortNrs,1);
end    

% Erzeuge ein Ergebnis-Struct
named_signals = struct();

named_signals.ParentalBlockPath = ParentBlocksOfSignals;
named_signals.ParentalBlockHandle = ParentBlockHdl;
named_signals.NameInDiagram     = NamesOfNamedSignals;
named_signals.SourceBlockPath   = StartingBlockOnce;
named_signals.SourceBlockPort   = PortNrs;
named_signals.SourceBlockHandle = SourceHdl;
named_signals.Handle            = HandlesOnce;

named_signals.NrSig = NrSig;

end

