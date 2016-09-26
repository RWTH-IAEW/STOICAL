% getJoinedSignals returns regular expression for joined signals 
%
% Syntax:  [ SignalLabelRegExp, NewSignalNames, JoinedSignalName, JoinedSignals ] = getJoinedSignals( SigTest, STOICAL )
%
% Inputs:
%    SigTest - 
%    STOICAL - 
%
% Outputs:
%    SignalLabelRegExp - regular expression signal label
%    NewSignalNames - 
%    JoinedSignalName - 
%    JoinedSignals - 
%
% Example: 
%
% See also: getLabelDefinitionFromModelWorkspace, getDefinedLabelRegExp,
% getDefaultLabelDefinition, getPossibleDefinedLabels

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

function [ SignalLabelRegExp, NewSignalNames, JoinedSignalName, JoinedSignals ] = getJoinedSignals( SigTest, STOICAL )

    [ Prefixes, ~ ] = getVariablePrefixes();
    JoinedSignalFilePrefix = Prefixes.JoinedSignals;
        
        %%
        if ~iscell(SigTest)
            SigTest = {SigTest};
        end
        
        NrOfSigRegExp2Join = length(SigTest);
        
        for iSig = 1:NrOfSigRegExp2Join

            filt_paramfoundem = ~cellfun(@isempty,regexp(STOICAL.SignalDefinition.LabelPath,SigTest(iSig)));
            siglabpath = STOICAL.SignalDefinition.LabelPath(filt_paramfoundem);

            %requirement: all signals to join must be defined in same "level"
            [uniquesigs, ~,parambelongstouniquesig] = unique(siglabpath);

            nrofoccurences = histc(parambelongstouniquesig,1:max(parambelongstouniquesig));

            filt_joinnecessary = nrofoccurences > 1;

            SignalLabelRegExp{iSig} = uniquesigs;

            NewSignalNames{iSig} = SignalLabelRegExp{iSig};

            JoinedSignalName{iSig} = cellfun(@(x) [JoinedSignalFilePrefix getmd5(x)],NewSignalNames{iSig},'UniformOutput',false);

            % change Signal Definition
                STOICAL.JoinedSignalDefinition = STOICAL.SignalDefinition;

                %filt_wasjoined = filt_joinnecessary(parambelongstouniqueparam,1); %OK
                JoinedSignals{iSig} = cell(max(parambelongstouniquesig),1);

                for iJoinSig = 1:max(parambelongstouniquesig)
                    if ~(filt_joinnecessary(iJoinSig))
                        %continue;
                    end

                    filt_pos = parambelongstouniquesig == iJoinSig;

                    JoinedSignals{iSig}{iJoinSig,1} = STOICAL.SignalDefinition.NameOfLogVar(filt_pos,:);

                    %STOICAL.JoinedSignalDefinition.NameOfLogVar(filt_pos,:) = ...
                    %    JoinedSignalName(iJoinSig,:);
                end

    %         SignalLabelRegExp(~filt_joinnecessary) = [];
    %         NewSignalNames(~filt_joinnecessary) = [];
    %         JoinedSignalName(~filt_joinnecessary) = [];
    %         JoinedSignals(~filt_joinnecessary) = [];
        end
end

