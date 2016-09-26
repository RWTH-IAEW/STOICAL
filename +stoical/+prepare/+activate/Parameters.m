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

system2load = STOICAL_MODEL;
system2check = [system2load]; %/#UNIT#PNB 2/#UNIT#Voltage Controller' '/#UNIT#PNB 1'

%load_system(system2check)
load_system(system2load);

%% Get Defined Labels
    [ STOICAL.LabelDefinition, IsDefault ] = stoical.Label.getLabelDefinitionFromModelWorkspace( system2load, 'STOICAL' );
    [ HIRARCHY_RegExp, SIGNAL_RegExp, PARAM_RegExp, RegExp_All, RegExp_DefaultVariant ] = ...
        stoical.Label.getDefinedLabelRegExp( STOICAL.LabelDefinition );    

%% 

named_params = stoical.Parameters.getListParametersWithRegExpName(system2check,PARAM_RegExp);

named_params = stoical.Parameters.setDefaultParamFieldEntries( named_params );

named_params = stoical.Parameters.setExplVarNamesForParams(named_params);

%% Define Labelpath for Parameters

    if named_params.NrParams > 0
    
        fullparamname = cellfun(@(x,y) [x '/' STOICAL.LabelDefinition.Parameters{1} y],...
            named_params.ParentalBlockPath,named_params.ParamName,...
            'UniformOutput',false);

        RegExprForParameterLabeling = ['(' HIRARCHY_RegExp ')|(' PARAM_RegExp ')'];

        named_params.LabelPath = cellfun(@(x) stoical.Label.Paths.path2labelstring(x,RegExprForParameterLabeling),...
            fullparamname,'UniformOutput',false);
    else
        named_params.LabelPath = cell(1,0);
    end

%% Try to get existing default values from file

    try
        savedparams  = getParametersFromModelWorkspace(system2load, 'STOICAL', 'ignoreUnfound', true );
        defparam = cell(size(named_params.LabelPath));
        defparam(:) = {'--------- no old value ----------'};
        
        if ~isempty(savedparams)
            tmpdefparam = reshape(savedparams.ParamDefaultValue,[],1);
            
            % Find out if the old ones still exist
            derparamlabelpath = savedparams.LabelPath;
            
            filt_stillexists = ismember(derparamlabelpath,named_params.LabelPath);
            filt_hasoldparam = ismember(named_params.LabelPath,derparamlabelpath);
            
            %make those still existing unique
            [uniqueOldLabelPath,oldIdx] = unique(derparamlabelpath(filt_stillexists));
            
            mapnew2uniqueold = mapNonuniqueAtoUniqueB(named_params.LabelPath,uniqueOldLabelPath);
            filt_available = mapnew2uniqueold ~= 0;
            mapnew2old = oldIdx(mapnew2uniqueold(filt_available));
            
            %test
            tmpdefparamstillexist = tmpdefparam(filt_stillexists);
            defparam(filt_available,1) = tmpdefparamstillexist(mapnew2old);
        end
    catch
        defparam = [];
    end

%% Lets see if there are identical Labelpath ... e.g. across Variants
    
    [uniqueLabelPath,idxa] = unique(named_params.LabelPath);
    map = stoical.General.SortAndMap.mapNonuniqueAtoUniqueB(named_params.LabelPath,uniqueLabelPath);
    
    nrOfUniqueParams = length(uniqueLabelPath);
    
%% Define Default Parameter Values
    %named_params = setActiveParamValuesAsDefault( named_params );
    
    ParamsDone = 0;
    uniqueParamsValues2set = cell(nrOfUniqueParams,1);
    
    while ParamsDone < nrOfUniqueParams
        % idx
            From = ParamsDone + 1;
            To   = min(ParamsDone + 10,nrOfUniqueParams);
    
        % Use Dialog Box
        prompt=uniqueLabelPath(From:To);
        name='Define Default Values for defined Parameters';
        numlines=1;

        if ~isempty(defparam)
            defaultanswer = defparam(idxa(From:To));
        else
            defaultanswer=cellfun(@num2str,num2cell(zeros(size(prompt))),'UniformOutput',false);
        end

        options.Resize='on';
        options.WindowStyle='normal';

        %answer=inputdlg(prompt,name,numlines,defaultanswer,options);   
        
        if isempty(defaultanswer)
            error([getToolboxName() ': User cancelation of Parameter Activation -> Repeat Activation !']);
            return;
            disp('This line should not be reached :-)');
        end

        uniqueParamsValues2set(From:To) = defaultanswer;
        ParamsDone = ParamsDone + 10;
    end
    
%% Test if all Values have been defined

    filt_nonewvaluedefined = ~cellfun(@isempty,regexp(uniqueParamsValues2set,'------'));
    
    if any(filt_nonewvaluedefined)
        error('Some new parameters have not been defined new values --> Redo');
    end
    
%% Write back to original order

    named_params.ParamDefaultValue = uniqueParamsValues2set(map,1);

%% Write Variables to Block Diagram
    named_params = stoical.Parameters.setModelParameters2ExplVar(named_params);

%% Save Lists 2 Model
    stoical.Parameters.writeParametersToModelWorkspace(named_params, system2load, 'STOICAL' );

