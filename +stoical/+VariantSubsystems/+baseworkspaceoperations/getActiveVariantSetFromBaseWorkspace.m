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

function [ ActiveVariantSet ] = getActiveVariantSetFromBaseWorkspace( NodeList )
%GETACTIVEVARIANTSETFROMBASEWORKSPACE Summary of this function goes here
%   Detailed explanation goes here

    delimiter = '|';

    %get active variant configuration as reflected in internal variables
    [ vars2set, ~ ] = stoical.VariantSubsystems.get.getallVSExplVarSettingForDefaultVariant( NodeList );
    ActiveVariantNrs = zeros(size(vars2set));
    for ivar = 1:size(vars2set,1)
        ActiveVariantNrs(ivar,1) = evalin('base',vars2set{ivar,1});
    end
    
    %convert 2 cell
    activevarnrscell = cellfun(@num2str,num2cell(ActiveVariantNrs),'UniformOutput',false);
    
% DON'T DO THIS, an update diagram is required which changes the model apparently        
%       Has the active variant set changed since the last run?
%         configuredVariantNrString = strjoin(reshape(activevarnrs,1,[],1),'#');
%         savedConfiguredVariantString{iRun,1} = configuredVariantNrString;
%         if ~strcmp(lastconfiguredVaraintNrString,configuredVariantNrString)
%             % Do we need to update to ensure correct setting detection of VS?
%             %
%             %  TO BE SURE: yes --> several extra seconds spend
%             %  ELSE      : no  --> may need to recompile because configuration has
%             %                      been wrongly detected, results will be correct though
%             %  Compromise: Only if variants have changed --> easily detectable
%             %              Allwasy done on first run before first simulation !
%             %
%             warning('off','all');
%             %set_param(system2load, 'SimulationCommand', 'update');
%             warning('on','all');
%             % save for next loop run
%             lastconfiguredVaraintNrString = configuredVariantNrString;
%         end
%         
% DON'T DO THIS, an update diagram is required which changes the model apparently        
%     %which are inactive varsys because of actual setting?
%         [BlockHandlesActiveVS] = find_system(bdroot,...
%             'SearchDepth',Inf,...
%             'FindAll','on',...
%             'LookUnderMasks','on',...
%             'LoadFullyIfNeeded','on',...
%             'Variants','ActiveVariants',...
%             'BlockType','SubSystem',...
%             'Variant','on'... %only Variant Subsystems
%             );
%         HdlsOfAll = NodeList.NodeHandle(NodeList.IsVariantSubsystem);
%         [isactiveVS] = ismember(HdlsOfAll,BlockHandlesActiveVS);
%     
%     %Set inactive to X
%         activevarnrs(~isactiveVS) = {'X'};
    
    ActiveVariantSetString = strjoin(reshape(activevarnrscell,1,[],1),delimiter);
   
    %ActiveVariantSetMD5 = getmd5(ActiveVariantSetString);
    
    %% Give back in default structure
    
    ActiveVariantSet.NrOfEntries = length(ActiveVariantNrs);
    
    ActiveVariantSet.EntryValue.Numeric  = ActiveVariantNrs;
    ActiveVariantSet.EntryValue.Mixed  = ActiveVariantNrs;
    ActiveVariantSet.EntryValue.String = activevarnrscell;
    
    ActiveVariantSet.AllEntriesValueString.BuildRelevant    = ActiveVariantSetString;
    ActiveVariantSet.AllEntriesValueString.NotBuildRelevant = '';
    ActiveVariantSet.AllEntriesValueString.All              = ActiveVariantSetString;
    
end

