% getSignalSimulationsMapFromCatalogue - 
%
% Syntax:  [ MapSignalsHaveSimulations, filt_exists ] = getSignalSimulationsMapFromCatalogue( SignalLabelRegExp, STOICAL, Overview, RelevantSimNamesOrdered )
%
% Inputs:
%    SignalLabelRegExp - 
%    STOICAL - 
%    Overview - 
%    RelevantSimNamesOrdered - 
%
% Outputs:
%    MapSignalsHaveSimulations - 
%    filt_exists - 
%
% Example: 
%
%
% See also: getActiveParametersFromCatalogue, getActiveVariantsFromCatalogue,
% writeActiveSetting2OverviewFile, loadCatalogue
%

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

function [ MapSignalsHaveSimulations, filt_exists ] = getSignalSimulationsMapFromCatalogue( SignalLabelRegExp, STOICAL, Overview, RelevantSimNamesOrdered )

    if nargin < 4
        RelevantSimNamesOrdered = {};
    end

    %%

    if ~iscell(SignalLabelRegExp)
        SignalLabelRegExp = {SignalLabelRegExp};
    end

    MapSignalsHaveSimulations  = cell(length(SignalLabelRegExp),1);

    for iSignal = 1:length(SignalLabelRegExp)
        CatalogueFileNamesSignals2Get = getAllSignalNamesForLabel( ...
        SignalLabelRegExp{iSignal}, STOICAL.SignalDefinition, Overview.SignalsInCatalogue);

        if isempty(RelevantSimNamesOrdered)
            filt_files = ismember(Overview.MapSignalsHaveSimulations(:,1),CatalogueFileNamesSignals2Get);
        else % restrict to those of interest
            filt_files = ismember(Overview.MapSignalsHaveSimulations(:,1),CatalogueFileNamesSignals2Get) & ...
                         ismember(Overview.MapSignalsHaveSimulations(:,2),RelevantSimNamesOrdered);
        end
        
        MapSignalsHaveSimulations{iSignal,1} = Overview.MapSignalsHaveSimulations(filt_files,:);
    end
    
    %% Rearrange Configurations per Map in order to retain same order
    
    if isempty(RelevantSimNamesOrdered)
        if length(SignalLabelRegExp) > 1
            % get order of first Map
                FirstMapConfigOrder = MapSignalsHaveSimulations{1,1}(:,2);

            % rearrange the others
                for iMap = 2:length(SignalLabelRegExp)
                    actualMap = MapSignalsHaveSimulations{iMap,1};
                    MapActual2FirstMap = mapNonuniqueAtoUniqueB(actualMap(:,2),FirstMapConfigOrder);
                    MapSignalsHaveSimulations{iMap,1} = actualMap(MapActual2FirstMap,:);
                end
        end
        
        filt_exists = true(size(FirstMapConfigOrder,1),1);
        
    else % known wanted order via "RelevantSimNamesOrdered"
        for iSignal = 1:length(SignalLabelRegExp)
            actualMap = MapSignalsHaveSimulations{iSignal,1};
            
            MapActual2Wanted = mapNonuniqueAtoUniqueB(RelevantSimNamesOrdered,actualMap(:,2)); % Wierum ???
            
            filt_exists = MapActual2Wanted ~= 0;
            
            %MapSignalsHaveSimulations{iSignal,1}( filt_exists,1:2) = actualMap(MapActual2Wanted(filt_exists),:);
            MapSignalsHaveSimulations{iSignal,1}( :,1:2) = actualMap(MapActual2Wanted(filt_exists),:);
            %MapSignalsHaveSimulations{iSignal,1}(~filt_exists,1:2) = {'' ''};
        end        
    end
    
end

