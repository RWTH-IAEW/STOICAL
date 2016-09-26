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

clc;
clearvars -except STOICAL_MODEL testCase;
close all;

system2load = STOICAL_MODEL;

system2check = [system2load];

load_system(system2check);

%% get possible Tokens
[ possibleTokens, count, problemcases ] = getPossibleDefinedLabels(system2check);

%% get std Labels

SL = getDefaultLabelDefinition();
RegExp = strjoin([SL.Hierarchical(:) SL.Signals(:) SL.Parameters(:) SL.DefaultVariant(:)],'|');

FullPossTokens = cellfun(@(x) ['#' x '#'],possibleTokens,'UniformOutput',false);

filt_isstdtoken = ~cellfun(@isempty,regexp(FullPossTokens,RegExp));

yesnostr = cell(size(filt_isstdtoken));
yesnostr(filt_isstdtoken) = {'yes'};

%% output result
clc

if ~isempty(possibleTokens)
    disp('Possible LABELS are with decreasing occurences:');
    fprintf('\n%10s | %5s | %5s\n','Name','Count','Is Default');
    disp('  -------------------------------');

    for i = 1:size(possibleTokens,1)
        fprintf('%10s | %5g | %5s\n',possibleTokens{i},count(i),yesnostr{i});
    end
    
    disp(' ');
    disp('   => Please define which are LABELS and which are parameter names ');
else
    disp('No possible Labels found');
end

if ~isempty(problemcases)
    disp(' ');
    disp('The following block names might create problems with STOICAL:');
    disp(' ');
    disp(' Names with single # ');
    disp('---------------------------------------');

    for i = 1:size(problemcases,1)
        disp([' - ' regexprep(problemcases{i},'\n',' ')]);
    end

    disp(' ');
    disp('   => Please consider cleaning them up');
end