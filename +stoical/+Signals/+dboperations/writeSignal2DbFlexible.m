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

function [ successfull ] = writeSignal2DbFlexible( Db, Table, signaldatacell, varargin )
%WRITESIGNAL2DB Summary of this function goes here
%   Detailed explanation goes here

%% Eingangsparameter SpecialParameters parsen
    p = inputParser;
    %               Name              Default   Type
    addParameter(p, 'FixedStepTimeWindow' ,[0 Inf 5E-5] ,@isnumeric);
    addParameter(p, 'UseWindow'       ,false    ,@islogical);
    addParameter(p, 'DiscardTime'     ,false    ,@islogical);
    addParameter(p, 'Signal'          ,{''}     ,@iscell);
    addParameter(p, 'VariantSet'      ,{''}     ,@iscell);
    addParameter(p, 'ParameterSet'    ,{''}     ,@iscell);
    
    addParameter(p, 'ModelConfigSet'  ,{''}     ,@iscell);
    addParameter(p, 'SPSConfigSet'    ,{''}     ,@iscell);
    addParameter(p, 'SimulationID'    ,{''}     ,@iscell);
    parse(p,varargin{:});

%% Basic checking

    if isa(Db,'database')
        if isconnection(Db)
            if isreadonly(Db)
                successfull = false;
                return;
            end
        else
            successfull = false;
            return;
        end
    else
        successfull = false;
        return;
    end

%% check if signals are timeseries

    filt_is_ts = cellfun(@(x) isa(x,'timeseries'),signaldatacell);
    
    if any(~filt_is_ts)
        successfull = false;
        return;
    end
    
%% extract and prepare core data from timeseries
    %user helper function to retrieve separated time and data
    if p.Results.UseWindow
        [timecell,datacell] = cellfun(@(x) getTimeDataFromTimeseries(x,p.Results.FixedStepTimeWindow),signaldatacell,'UniformOutput',false);
    else
        [timecell,datacell] = cellfun(@(x) getTimeDataFromTimeseries(x),signaldatacell,'UniformOutput',false);
    end
    
    if p.Results.DiscardTime
        % write only TimeWindowInfo to database --> much smaller for long
        % simulations
        timecell = cellfun(@(x) p.Results.FixedStepTimeWindow ,timecell,'UniformOutput',false);
    end
    
    %create single data lines
%         lengthtime = cellfun(@numel,timecell);
%         lengthdata = cellfun(@numel,datacell);
% 
%         multipledatacols = lengthdata > lengthtime;
% 
%         if any(multipledatacols)
%             datacell = cellfun(@(x) reshape(x,[],1),datacell,'UniformOutput',false); %write below each other
%         end

    %general reshape
        timecell = cellfun(@(x) reshape(x,1,[]),timecell,'UniformOutput',false); %write below each other
        datacell = cellfun(@(x) reshape(x,1,[]),datacell,'UniformOutput',false); %write below each other
    
    %convert type
        timecell = cellfun(@(x) typecast(x,'uint8'),timecell,'UniformOutput',false);
        datacell = cellfun(@(x) typecast(x,'uint8'),datacell,'UniformOutput',false);
        
%% Write Signal to database
    default_headers = getDBHeaders();
    cellArrayColumnsNames = default_headers.SignalTimeseriesTable;
    
    successfull = sqlite3_batchwrite( ...
        Db, Table, cellArrayColumnsNames, ...
        [p.Results.Signal p.Results.VariantSet p.Results.ParameterSet ...
         p.Results.ModelConfigSet p.Results.SPSConfigSet ...
         p.Results.SimulationID ...
         timecell datacell] );
    
end

