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

function tests = testStoicalExampleModelCreation
tests = functiontests(localfunctions);
end

function teardown(testCase)
close all;
bdclose;
end

function testConfigureDefineModelHierarchie(testCase)
STOICAL_MODEL = 'STOICAL_example_1_Step00_ExistingModel';
analyse_ExistingLabelDefinitions
testCase.assertEqual(possibleTokens, {});
testCase.assertEqual(count, {});
testCase.assertEqual(yesnostr, {});


STOICAL_MODEL = 'STOICAL_example_1_Step01a_DefineModelHierarchie';
analyse_ExistingLabelDefinitions
testCase.assertEqual(possibleTokens, {'UNIT'});
testCase.assertEqual(count, 2);
testCase.assertEqual(yesnostr, {'yes'});

STOICAL_MODEL = 'STOICAL_example_1_Step01b_DefineParameters';
analyse_ExistingLabelDefinitions
testCase.assertEqual(possibleTokens, {'PARAM'; 'UNIT'});
testCase.assertEqual(count, [2;2]);
testCase.assertEqual(yesnostr, {'yes'; 'yes'});



STOICAL_MODEL = 'STOICAL_example_1_Step01c_DefineSignals';
analyse_ExistingLabelDefinitions
testCase.assertEqual(possibleTokens, {'PARAM'; 'SIG'; 'UNIT'});
testCase.assertEqual(count, [2;2;2]);
testCase.assertEqual(yesnostr, {'yes'; 'yes'; 'yes'});


end

function testConfigureSimulinkOutputSaveOptions(testCase)
STOICAL_MODEL = 'STOICAL_example_1_Step01c_DefineSignals';

configure_SimulinkOutputSaveOptions

testCase.verifyEqual(get_param(STOICAL_MODEL, 'SignalLoggingName'), 'STOICAL_LoggedSignals');
end