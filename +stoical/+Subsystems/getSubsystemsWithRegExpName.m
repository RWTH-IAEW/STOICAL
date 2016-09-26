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

function [ matching_subsys ] = getSubsystemsWithRegExpName( str_model, RegExpName )
%GETLISTNAMEDSIGNALS Summary of this function goes here
%   Detailed explanation goes here

% Prüfe ob System geladen ist
% open_bd = find_system('type', 'block_diagram');
% if ~any(strcmp(open_bd,str_model))
%     load_system(str_model)
% end

% Finde alle "Leitungen" in allen Varianten etc.
[HdlSubsys] = find_system(str_model,...
    'FindAll','on',...
    'LookUnderMasks','on',...
    'LoadFullyIfNeeded','on',...
    'RegExp','on',...
    'Variants','AllVariants',...
    'RegExp','on',...
    'Type','Block',...
    'Name',RegExpName...
    );

% Ermittle die Namen der Blöcke
NamesSubsys = get_param(HdlSubsys,'Name');

% Pfade ermitteln
PathSubsys = getfullname(HdlSubsys);

if ~iscell(PathSubsys)
    PathSubsys = {PathSubsys};
end

%Eltern-Block-Pfad ermitteln
ParentPathSubsys = get_param(PathSubsys,'Parent');

% Erzeuge ein Ergebnis-Struct
matching_subsys = struct();

matching_subsys.ParentalBlockPath   = ParentPathSubsys;
matching_subsys.ParentalBlockHandle = cell2mat(get_param(ParentPathSubsys,'Handle'));
matching_subsys.NameInDiagram       = NamesSubsys;
matching_subsys.Path                = PathSubsys;
matching_subsys.Handle              = HdlSubsys;

end

