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

function [ named_params ] = getListParametersWithRegExpName( str_model, RegExpName )
%GETLISTNAMEDSIGNALS Summary of this function goes here
%   Detailed explanation goes here

% Finde alle Blöcke mit Markierung als Parameter in allen Varianten etc.
[BlockHdlsFound] = find_system(str_model,...
    'FindAll','on',...
    'FollowLinks', 'on', ...
    'LookUnderMasks','on',...
    'LoadFullyIfNeeded','on',...
    'RegExp','on',...
    'Variants','AllVariants',...
    'Type','Block',...
    'Name',RegExpName...
    );

if isempty(BlockHdlsFound)
    named_params = struct();
    named_params.NrParams            = 0;
    return;
end

% Ermittle die Namen der Paremeterbehafteten Blöcke
FullParamBlockNames = get_param(BlockHdlsFound,'Name');
if ~iscell(FullParamBlockNames)
    FullParamBlockNames = {FullParamBlockNames};
end

% Separate Block Name (PREFIX) / MARKER / ParamName(s)
strparts = cellfun(@(x) strsplit(x,RegExpName,'DelimiterType','RegularExpression'),...
                   FullParamBlockNames,'UniformOutput',false);
PreMarkerText  = cell(size(strparts,1),1);
PostMarkerText = cell(size(strparts,1),1);
for ip = 1:size(strparts,1)
    hlpvartmp = strparts{ip,:};
    PreMarkerText{ip,1}   = hlpvartmp{1};
    PostMarkerText{ip,1}  = hlpvartmp{end};
end

% Ermittle die Einzel-Parameter
SingleParamsList = cellfun(@(x) strsplit(x,'#'),...
                   PostMarkerText,'UniformOutput',false);
% Ermittle die Anzahl der Parameter   
ParamCountOfBlk = cellfun(@length,SingleParamsList);

%SingleVarNameList
SingleVarNameList = cellfun(@(x) x{1,1},SingleParamsList,'UniformOutput',false);

filt_multiparam = ParamCountOfBlk > 1;
if any(filt_multiparam)
    %resize the vars
        %get additional nr of entries
        AddRowCount = sum(ParamCountOfBlk - 1);
        OrigRowCount = size(FullParamBlockNames,1);
        NewRowCount = OrigRowCount + AddRowCount;
        %resize
        FullParamBlockNames{NewRowCount,1} = {};
        PreMarkerText{NewRowCount,1} = {};
        BlockHdlsFound(NewRowCount,1) = -1;
        SingleVarNameList{NewRowCount,1} = {};

    lastsetrow = OrigRowCount;
    for imult = reshape(find(filt_multiparam),1,[])
        for iaddvar = 2:ParamCountOfBlk(imult)
            FullParamBlockNames{lastsetrow+1,1} = FullParamBlockNames{imult,1};
            PreMarkerText{lastsetrow+1,1}       = PreMarkerText{imult,1};
            BlockHdlsFound(lastsetrow+1,1)      = BlockHdlsFound(imult,1);
            SingleVarNameList{lastsetrow+1,1}   = SingleParamsList{imult,1}{iaddvar};
            lastsetrow = lastsetrow + 1;
        end
    end
end

% Erzeuge ein Ergebnis-Struct
named_params = struct();

named_params.BlkNameFull         = FullParamBlockNames;
named_params.BlkNameShort        = PreMarkerText;
named_params.BlkHandle           = BlockHdlsFound;
named_params.ParamName           = SingleVarNameList;
% problematic, as may be a regexp: named_params.ParamNameWithMarker = cellfun(@(x) [RegExpName x],PostMarkerText,'UniformOutput',false);

    % Hohle die vollen Pfadnamen
    BlkPath = getfullname(BlockHdlsFound);
    if ~iscell(BlkPath)
        BlkPath = {BlkPath};
    end

named_params.BlkPath             = BlkPath;
named_params.BlkType             = get_param(BlockHdlsFound,'BlockType');
named_params.BlkMaskType         = get_param(BlockHdlsFound,'MaskType');

named_params.ParentalBlockPath   = get_param(named_params.BlkPath,'Parent');
named_params.ParentalBlockHandle = cell2mat(get_param(named_params.ParentalBlockPath,'Handle'));

%Determine the next subsystem which the parameters belong to
filt_ParamdDefOnSubSys = strcmp(named_params.BlkType,'SubSystem');
named_params.Belongs2SubsystemHdl = named_params.ParentalBlockHandle;
named_params.Belongs2SubsystemHdl(filt_ParamdDefOnSubSys) = ...
    named_params.BlkHandle(filt_ParamdDefOnSubSys);

named_params.NrParams            = size(named_params.BlkPath,1);

%% Check if subsystems with parameters defined have corresponding mask values
    
    % find all subsystems with params
    filt_subsystems = strcmp(named_params.BlkType,'SubSystem');
    
    for iParamSubsys = reshape(find(filt_subsystems),1,[])
        % get the non-commona parameters of the subsystems
        SubHdl = named_params.BlkHandle(iParamSubsys);
        SpecialParams = stoical.General.SpecialSubsystemParameters.getSpecialSubsystemParameters(SubHdl);
        
        if ~isempty(SpecialParams{1})
            is_Param_inMask = ismember(SpecialParams{1},named_params.ParamName{iParamSubsys});
        else
            is_Param_inMask = false;
        end
        
        % check if there is a mask
        no_mask = strcmp(get_param(SubHdl,'Mask'),'off');
        
        if no_mask
            error([stoical.InternalDataStorage.getToolboxName() ': No Subsystem Mask found for Subsystem with defined Parameters: "' named_params.BlkPath{iParamSubsys} '" ! -> Check & Repeat Activation']);
        else
            if ~is_Param_inMask 
                error([stoical.InternalDataStorage.getToolboxName() ': Parameter "' named_params.ParamName{iParamSubsys} ...
                    '" not found in Subsystem Mask "' named_params.BlkPath{iParamSubsys} '" ! -> Check & Repeat Activation']);
            end
        end
    end

end

