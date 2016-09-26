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

function [ signaldatacell, signalsretrieved, simulationsretrieved, ...
           otherparams, otherparamsdata ] = ...
                readSignalFromDb( Db, Table, signalnamecell, simulationcell )
%WRITESIGNAL2DB Summary of this function goes here
%   Detailed explanation goes here


%% Basic checking

    if isa(Db,'database')
        if isconnection(Db)
            if isreadonly(Db)
                %successfull = false;
                return;
            end
        else
            %successfull = false;
            return;
        end
    else
        %successfull = false;
        return;
    end

    % is there some empty?
        nosignalsgiven       = cellfun(@isempty,signalnamecell);
        nosimulationIDsgiven = cellfun(@isempty,simulationcell);
    
    if ~iscell(signalnamecell)
        signalnamecell = {signalnamecell};
    end
    
    if ~iscell(simulationcell)
        simulationcell = {simulationcell};
    end

%% Prepare Query statements

    %% Analyse data retrieval request
        
        % Only one Signal to get?
            uniquesignals = unique(signalnamecell(~nosignalsgiven));
            if size(uniquesignals,1) == 1
                query_onlyonesig = true;
                if isempty(uniquesignals{:})
                    nosignalsgiven = true;
                    query_onlyonesig = false;
                end
            else
                query_onlyonesig = false;
            end
                        
        % Only one simulationID to get?
            uniquesimulationIDs = unique(simulationcell(~nosimulationIDsgiven));
            if size(uniquesimulationIDs,1) == 1
                query_onlyonesimulationID = true;
                if isempty(uniquesimulationIDs{:})
                    nosimulationIDsgiven = true;
                    query_onlyonesimulationID = false;
                end
            else
                query_onlyonesimulationID = false;
            end
            
        % Default Parts
            PRE  = 'SELECT * FROM ';
            POST = ' WHERE ';
            
        % cases
            if query_onlyonesig & query_onlyonesimulationID
                QUERY = [PRE Table POST '(( signal = "' uniquesignals{:} '") AND ( simulationID = "' uniquesimulationIDs{:} '"));'];
            end

            if query_onlyonesig & ~query_onlyonesimulationID
                if nosimulationIDsgiven
                    QUERY = [PRE Table POST '( signal = "' uniquesignals{:} '");'];
                else
                    SETBUILD = ['("' strjoin(reshape(simulationcell((~nosimulationIDsgiven)),1,[]),'","') '")'];
                    QUERY = [PRE Table POST '(( signal = "' uniquesignals{:} '") AND ( simulationID IN ' SETBUILD ' ));'];
                end
            end
            
            if ~query_onlyonesig & query_onlyonesimulationID
                if nosignalsgiven
                    QUERY = [PRE Table POST '( simulationID = "' uniquesimulationIDs{:} '");'];
                else
                    SETBUILD = ['("' strjoin(reshape(signalnamecell(~nosimulationIDsgiven),1,[]),'","') '")'];
                    QUERY = [PRE Table POST '(( simulationID = "' uniquesimulationIDs{:} '") AND ( signal IN ' SETBUILD ' ));'];
                end
            end
            
            if ~query_onlyonesig & ~query_onlyonesimulationID
                
                if nosignalsgiven & nosimulationIDsgiven
                    QUERY = [PRE Table ';'];
                else
                    if nosignalsgiven & ~nosimulationIDsgiven
                        SETBUILD = ['("' strjoin(reshape(simulationcell(~nosimulationIDsgiven),1,[]),'","') '")'];
                        QUERY = [PRE Table POST '( simulationID IN ' SETBUILD ' );'];
                    elseif ~nosignalsgiven & nosimulationIDsgiven
                        SETBUILD = ['("' strjoin(reshape(signalnamecell(~nosimulationIDsgiven),1,[]),'","') '")'];
                        QUERY = [PRE Table POST '( signal IN ' SETBUILD ' );'];
                    else
                        PARTCONDCELL = cellfun(@(x,y) ['(( simulationID = "' y '") AND ( signal = "' x '"))'],signalnamecell,simulationcell,'UniformOutput',false);
                        CONDBUILD = ['(' strjoin(reshape(PARTCONDCELL,1,[]),' OR ') ')'];

                        QUERY = [PRE Table POST CONDBUILD ';'];
                    end
                end
            end
            
%% read from db

    ResultRAW = sqlite3_batchquery(Db, QUERY);
    
    if isempty(ResultRAW)
        signaldatacell   = {[]};
        signalsretrieved = {''};
        otherparams = {''};
        return;
    end
    
%% Do some typecasting
    default_headers = getDBHeaders();
    ColNames = default_headers.SignalTimeseriesTable;

    sigidx  = find(strcmp(ColNames,'signal'));
    simidx  = find(strcmp(ColNames,'simulationID'));
    timeidx = find(strcmp(ColNames,'timeblob'));
    dataidx = find(strcmp(ColNames,'datablob'));
    
    restidx = 1:length(ColNames);
    restidx([sigidx timeidx dataidx simidx]) = [];
    
    %convert type
        timecell = cellfun(@(x) typecast(x,'double'),ResultRAW(:,timeidx),'UniformOutput',false);
        datacell = cellfun(@(x) typecast(x,'double'),ResultRAW(:,dataidx),'UniformOutput',false);

    %check if time is a fixed step compressed format and reconstruct
        timecell = cellfun(@(x) reconstructTime(x),timecell,'UniformOutput',false);

    %revert to original shape
        lengthtime = cellfun(@numel,timecell);
        lengthdata = cellfun(@numel,datacell);
        
        multipledatacols = lengthdata > lengthtime;

        if any(multipledatacols)
            datacell = cellfun(@(x,y) reshape(x,y,[]),datacell,num2cell(lengthtime),'UniformOutput',false); %write below each other
        end

    % Get actual SimulationID order of read data
    
        simulationsretrieved = ResultRAW(:,simidx);
        
        MapIs2Should = mapNonuniqueAtoUniqueB(simulationcell,simulationsretrieved);
        filt_exists  = MapIs2Should ~= 0;
        
    % Recreate Timeseries Objects        
        signaldatacell(filt_exists,:) = cellfun(@(t,d) timeseries(d,t),timecell(MapIs2Should(filt_exists)),datacell(MapIs2Should(filt_exists)),'UniformOutput',false);

    % What was retrieved?    
        signalsretrieved(filt_exists) = ResultRAW(MapIs2Should(filt_exists),sigidx);
        
        simulationsretrieved(filt_exists) = ResultRAW(MapIs2Should(filt_exists),simidx);
        
        otherparams      = ColNames(:,restidx);
        otherparamsdata(filt_exists,:)  = ResultRAW(MapIs2Should(filt_exists),restidx);

end

