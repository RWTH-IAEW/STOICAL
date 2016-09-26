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

function [ var2set, value2set ] = getVSExplVarSettingforVariant( VariantSubsystem, Variant, NodeList, LineBreakRepStr )
%GETVSEXPLVAR2SETFORVARIANT Summary of this function goes here
%   Detailed explanation goes here

%% Basic checking
    if ~any(NodeList.IsVariantSubsystem)
        % No Variant Subsystems in System
        var2set = cell(0,0);
        value2set = cell(0,0);
        warning([getToolboxName() ': No Variant Subsystems contained in model while trying to set one! -> Ignoring']);
        return;
    end

%% Type of Value of Variant Subsystem

    VS_IDX = [];

    if isstr(VariantSubsystem)
        expression = '[\n\r]';
        replace = LineBreakRepStr;

        % Ersetze Zeilenumbrüche in allen Vergleichpfadens
        VS_path  = getfullname(NodeList.NodeHandle(NodeList.IsVariantSubsystem,:));
        VS_path  = regexprep(VS_path,expression,replace);
        
        % Ersetze Zeilenumbrüche im zu suchenden Pfad
        VariantSubsystem  = regexprep(VariantSubsystem ,expression,replace);

        % gibt es einen match?
        idxvspath = find(ismember(VS_path,VariantSubsystem));
        
        if isempty(idxvspath)
            error('Could not find a matching Variant Subsystem Block for given path');
        end

        truevsidx = find(NodeList.IsVariantSubsystem);

        VS_IDX = truevsidx(idxvspath);
        if NodeList.IsVariantSubsystem(VS_IDX,:) ~= 1
            error('Given Handle is NOT a Virtual Subsystem');
        end
        
    else
        if isnumeric(VariantSubsystem)
            %is it a handle or an index in NodeList
            filt_ishdl = ismember(NodeList.NodeHandle,VariantSubsystem);
            if sum(filt_ishdl) == 1
                % seems to be a handle
                VS_IDX = find(filt_ishdl);
                if NodeList.IsVariantSubsystem(VS_IDX,:) ~= 1
                    error('Given Handle is NOT a Virtual Subsystem');
                end
            else
                if floor(VariantSubsystem) == VariantSubsystem
                    % ist eine Ganzzahl
                    if (VariantSubsystem > 0) & (VariantSubsystem <= length(NodeList.IsVariantSubsystem))
                        %might be index in NodeList
                        if NodeList.IsVariantSubsystem(VariantSubsystem,:) == 1
                            VS_IDX = VariantSubsystem;
                        else
                            error('Could not find out Virtual Subsystem input data type');
                        end
                    else
                        error('Could not find out Virtual Subsystem input data type');
                    end
                else
                    disp(['Variant to set: ' Variant]);
                    error('Could not find out Virtual Subsystem input data type');
                end
            end
        else
            error('Could not process Virtual Subsystem input data type');
        end
    end

%% Type of Value of Variant Subsystem

    Variant_IDX = [];

    if isstr(Variant)
        expression = '[\n\r]';
        replace = LineBreakRepStr;

        VariantsIdxes = NodeList.VSVariantsNodeIdx{VS_IDX,1};

        % Replace Linebreaks in Variant Names
        NamesVars = NodeList.NodeName(VariantsIdxes,:);
        NamesVars = cellfun(@(x) regexprep(x,expression,replace),NamesVars,'UniformOutput',false);
        
        % Replace Whitespace in Variant Names
        NamesVars = cellfun(@(x) regexprep(x,'\s',''),NamesVars,'UniformOutput',false);
        
        % Replace Linebreaks in given Variant String
        Variant = regexprep(Variant,expression,replace);
        Variant = regexprep(Variant,'\s','');
        
        %subidx = find(ismember(NamesVars,Variant));
        test = regexp(NamesVars,Variant);
        subidx = find(~cellfun(@isempty,test));
        
        if isempty(subidx)
            disp(NodeList.LabelPath(VS_IDX,:));
            disp(['Searched for Variant "' Variant '"']);
            error('Could not find a matching Variant name');
        end
        
        if length(subidx) > 1
            disp(['Searched for Variant "' Variant '"']);
            disp(NamesVars(subidx));
            error('Variant Search pattern does not resolve unique Variant');
        end
        
        Variant_IDX = VariantsIdxes(subidx,1);
        
    else
        if isnumeric(Variant)
            %is it a handle or an index in NodeList
            filt_ishdl = ismember(NodeList.NodeHandle,Variant);
            if sum(filt_ishdl) == 1
                % seems to be a handle
                Variant_IDX = find(filt_ishdl);
                if NodeList.IsVariant(Variant_IDX,:) ~= 1
                    error('Given Handle is NOT a Variant');
                end
            else
                if floor(Variant) == Variant
                    % ist eine Ganzzahl
                    if (Variant > 0) & (Variant <= NodeList.VSVariantsCount(VS_IDX,:))
                        VariantsIdxes = NodeList.VSVariantsNodeIdx{VS_IDX,1};
                        Variant_IDX = VariantsIdxes(Variant);
                    else
                        error('Could not find out Variant input data type');
                    end
                else
                    error('Could not find out Variant input data type');
                end
            end
        else
            disp(['Problem while setting Variant of VS : ' getfullname(VariantSubsystem)]);
            disp(['Variant Variable has class: ' class(Variant) ]);
            error('Could not process Variant input data type');
        end
    end    
    
%% Reply

    var2set = NodeList.VSControlVariable{VS_IDX,:};
    value2set = NodeList.VSVariantHasNr(Variant_IDX,:);
    
end

