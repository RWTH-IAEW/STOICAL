% getSimulinkModelConfiguration returns information about active simulink model configuration
%
% Syntax:  ActiveSimulinkConfigurationSet = getSimulinkModelConfiguration( systemname )
%
% Inputs:
%    systemname - simulink model name
%
% Outputs:
%    ActiveSimulinkConfigurationSet - active simulink configuration set
%
% Example:
%    STOICAL_MODEL = 'STOICAL_example_1'
%    ActiveSimulinkConfigurationSet = getSimulinkModelConfiguration( STOICAL_MODEL );
%
% See also: getActiveConfigurationAndParameters, getSimPowerSystemsV2Configuration

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

function [ ActiveConfigurationSet ] = getSimulinkModelConfiguration( model )
% TODO: skip eval, as num2str uses eval !!!!

nrformatunified = '%20.15e';

delimiter = '|';

%% Define the parameters critical for compilation

SolverChoice = {...
    'Solver',...
    'SolverName',...
    'SolverResetMethod',...
    'SolverJacobianMethodControl',...
    'SolverType'...
    };

SolverOptions = {...
    'AbsTol',...
    'ConsecutiveZCsStepRelTol',...
    'InitialStep',...
    'InsertRTBMode',...
    'MaxConsecutiveMinStep',...
    'MaxConsecutiveZCs',...
    'MaxNumMinSteps',...
    'MaxOrder',...
    'MaxStep',...
    'MinStep',...
    'OutputOption',...
    'Refine',...
    'RelTol',...
    'ShapePreserveControl',...
    'ZcThreshold',...
    'ExtrapolationOrder',...
    'FixedStep',...
    'NumberNewtonIterations',...
    'SampleTimeConstraint',...
    'SolverMode'...
    };

ConfigParamsWithRecompile = [SolverChoice SolverOptions];

ConfigParamsWithRecompile = reshape(ConfigParamsWithRecompile,[],1);

%% Define Parametrs of Interest for Storage or Analysis

TimespanOfSim = {...
    'StartTime',...
    'StopTime'...
    };

ConfigParamsOfInterest = TimespanOfSim;

ConfigParamsOfInterest = reshape(ConfigParamsOfInterest,[],1);

%%
activeConfigSetobj = getActiveConfigSet(model);

%%

ValuesWithRecompile = cell(size(ConfigParamsWithRecompile));

for iP = 1:length(ConfigParamsWithRecompile)
    try
        ValuesWithRecompile{iP,1} = get_param(activeConfigSetobj,ConfigParamsWithRecompile{iP});
    catch
        ValuesWithRecompile{iP,1} = [];
    end
end

%%

% Try to eval the parameters left as strings
EvaledParams = cell(size(ValuesWithRecompile,2),1);
for iVar = 1:length(ValuesWithRecompile)
    try
        EvaledParams{iVar,1} = eval(ValuesWithRecompile{iVar});
    catch
        EvaledParams{iVar,1} = [];
    end
end
filt_isevaled = ~cellfun(@isempty,EvaledParams);
ValuesWithRecompile(filt_isevaled) = EvaledParams(filt_isevaled);

ValuesWithRecompileMixed = ValuesWithRecompile;

% Replace numerical values with unified formating
filt_isnumeric_rebuild = cellfun(@isnumeric,ValuesWithRecompile);
NumVals = cell(size(ValuesWithRecompile,2),1);
NumVals(filt_isnumeric_rebuild,1) = ValuesWithRecompile(filt_isnumeric_rebuild);
NumValsUniqueStr = cellfun(@(x) sprintf(nrformatunified,x),NumVals(filt_isnumeric_rebuild,:),'UniformOutput',false);
ValuesWithRecompile(filt_isnumeric_rebuild) = NumValsUniqueStr;

ValuesWithRecompileString = ValuesWithRecompile;

%%

ValuesOfInterest = cell(size(ConfigParamsOfInterest));

for iP = 1:length(ConfigParamsOfInterest)
    try
        ValuesOfInterest{iP,1} = get_param(activeConfigSetobj,ConfigParamsOfInterest{iP});
    catch
        ValuesOfInterest{iP,1} = [];
    end
end

%%

% Try to eval the parameters left as strings
EvaledParams = cell(size(ValuesOfInterest,2),1);
for iVar = 1:length(ValuesOfInterest)
    try
        EvaledParams{iVar,1} = eval(ValuesOfInterest{iVar});
    catch
        EvaledParams{iVar,1} = [];
    end
end
filt_isevaled = ~cellfun(@isempty,EvaledParams);
ValuesOfInterest(filt_isevaled) = EvaledParams(filt_isevaled);

ValuesOfInterestMixed = ValuesOfInterest;

% Replace numerical values with unified formating
filt_isnumeric = cellfun(@isnumeric,ValuesOfInterest);
NumVals = cell(size(ValuesOfInterest,2),1);
NumVals(filt_isnumeric,1) = ValuesOfInterest(filt_isnumeric);
NumValsUniqueStr = cellfun(@(x) sprintf(nrformatunified,x),NumVals(filt_isnumeric,:),'UniformOutput',false);
ValuesOfInterest(filt_isnumeric) = NumValsUniqueStr;

ValuesOfInterestString = ValuesOfInterest;

%% Give back in default structure

ActiveConfigurationSet.NrOfEntries = length([ValuesWithRecompileMixed;ValuesOfInterestMixed]);


ActiveConfigurationSet.EntryValue.Mixed   = [ValuesWithRecompileMixed;ValuesOfInterestMixed];
ActiveConfigurationSet.EntryValue.String  = [ValuesWithRecompileString;ValuesOfInterestString];

ActiveConfigurationSet.EntryValue.Numeric = cell(size(ActiveConfigurationSet.EntryValue.Mixed));
ActiveConfigurationSet.EntryValue.Numeric( [filt_isnumeric_rebuild;filt_isnumeric],:) = ...
    ActiveConfigurationSet.EntryValue.Mixed( [filt_isnumeric_rebuild;filt_isnumeric],:);

ActiveConfigurationSet.EntryValue.Names   = [ConfigParamsWithRecompile; ConfigParamsOfInterest];


ActiveConfigurationSet.AllEntriesValueString.BuildRelevant    = ...
    strjoin(reshape(ValuesWithRecompileString,1,[]),delimiter);
ActiveConfigurationSet.AllEntriesValueString.NotBuildRelevant = ...
    strjoin(reshape(ValuesOfInterestString,1,[]),delimiter);
ActiveConfigurationSet.AllEntriesValueString.All              = ...
    strjoin(reshape([ValuesWithRecompileString;ValuesOfInterestString],1,[]),delimiter);

end

