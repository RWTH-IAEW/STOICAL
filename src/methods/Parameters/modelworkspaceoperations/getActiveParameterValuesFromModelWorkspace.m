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

function [ ActiveValueSet ] = getActiveParameterValuesFromModelWorkspace( systemname, named_params )
%GETACTIVEVARIANTSETFROMBASEWORKSPACE Summary of this function goes here
%   Detailed explanation goes here

    nrformatunified = '%20.15e';

    % Get Model Workspace handle
        hws = get_param(systemname,'ModelWorkspace');

    delimiter = '|';
    
    if named_params.NrParams == 0
        ActiveValueSet.NrOfEntries = 0;

        ActiveValueSet.EntryValue.Numeric = cell(0,1);
        ActiveValueSet.EntryValue.Mixed   = cell(0,1);
        ActiveValueSet.EntryValue.String  = cell(0,1);

        ActiveValueSet.AllEntriesValueString.BuildRelevant    = '';
        ActiveValueSet.AllEntriesValueString.NotBuildRelevant = '';
        ActiveValueSet.AllEntriesValueString.All              = '';
        return;
    end

    %get active variant configuration as reflected in internal variables
    [ vars2set, ~ ] = getAllParams2DefaultValues( named_params );
    ActiveValueStr = cell(size(vars2set));
    ActiveValueNum = cell(size(vars2set));
    filt_eval_failed = false(size(vars2set));
    
    for ivar = 1:size(vars2set,1)
        ActiveValueStr{ivar,1} = hws.getVariable(vars2set{ivar,1});
        try
            % we want to eval if possible
            ActiveValueNum{ivar,1} = str2num(ActiveValueStr{ivar,1});
            if isempty(ActiveValueNum{ivar,1}) && ...
               ~isempty(ActiveValueStr{ivar,1})
                filt_eval_failed(ivar,1) = true;
            end
        catch
            filt_eval_failed(ivar,1) = true;
        end
    end
    
    ActiveValueStrUnified = cellfun(@(x) num2str(x,nrformatunified),ActiveValueNum,...
                                    'UniformOutput',false);
    ActiveValueStrUnified(filt_eval_failed) = ActiveValueStr(filt_eval_failed);
    
    ActiveValuesSetString = strjoin(reshape(ActiveValueStrUnified,1,[],1),delimiter);
   
    %ActiveValuesSetMD5 = getmd5(ActiveValuesSetString);
    
    ActiveValuesMixed = ActiveValueStr;
    ActiveValuesMixed(~filt_eval_failed) = ActiveValueNum(~filt_eval_failed);
    
    %% Give back in default structure
    
    ActiveValueSet.NrOfEntries = length(ActiveValueStr);
    
    ActiveValueSet.EntryValue.Numeric = ActiveValueNum;
    ActiveValueSet.EntryValue.Mixed   = ActiveValuesMixed;
    ActiveValueSet.EntryValue.String  = ActiveValueStrUnified;
    
    ActiveValueSet.AllEntriesValueString.BuildRelevant    = '';
    ActiveValueSet.AllEntriesValueString.NotBuildRelevant = ActiveValuesSetString;
    ActiveValueSet.AllEntriesValueString.All              = ActiveValuesSetString;

end

