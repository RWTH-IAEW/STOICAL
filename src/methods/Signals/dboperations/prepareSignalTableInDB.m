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

function [ successfull ] = prepareSignalTableInDB( Db, Table )
%PREPARESIGNALTABLEINDB Summary of this function goes here
%   Detailed explanation goes here

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

%% Create Table    

%get headers
    default_headers = getDBHeaders();
    cellArrayColumnsNames = default_headers.SignalTimeseriesTable;
    cellArrayColumnsNamesDataType = default_headers.SignalTimeseriesTableDatatype;
    
% get a blob indicator
    isblob = ~cellfun(@isempty,regexp(cellArrayColumnsNamesDataType,'BLOB'));
    
%create fields in query
    fieldcell = cellfun(@(x,y) [' ' x ' ' y],cellArrayColumnsNames,cellArrayColumnsNamesDataType,...
        'UniformOutput',false);
    fieldstring = strjoin(reshape(fieldcell,1,[]),',');
    
    noblobfieldstring = strjoin(reshape(cellArrayColumnsNames(~isblob),1,[]),',');
    
try    
    Result = sqlite3_query(Db,...
       ['CREATE TABLE IF NOT EXISTS ' Table ' (' fieldstring ');']); %OK
    Result = sqlite3_query(Db,...
       ['CREATE VIEW ' Table '_noBLOB' ' AS SELECT ' noblobfieldstring ' FROM ' Table ';']); %OK
    successfull = true;
catch
end

end

