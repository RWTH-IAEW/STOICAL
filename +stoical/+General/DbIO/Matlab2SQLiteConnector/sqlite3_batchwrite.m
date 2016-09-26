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

function [ success ] = sqlite3_batchwrite( hConnection, tableName, cellArrayColumnsNames, data )
%SQLITE3_BATCHWRITE Summary of this function goes here
%   Detailed explanation goes here
    
    success = 1;

    %check if connection exists and if writeable
    if ~isconnection(hConnection) || isreadonly(hConnection)
        success = 0;
        warning('Connection not available OR readonly');
        return;
    end
    
    %check nr cols data vs ColNames
    if size(cellArrayColumnsNames,2) ~= size(data,2)
        success = 0;
        warning('Column size mismatch data - colnames');
        %return;
    end

    %set autocommit to off and save status
    try
        savedAutoCommitgetStatus = get(hConnection,'AutoCommit');
        set(hConnection,'AutoCommit','off');
    catch
        success = 0;
    end
     
    %try
        %write data in transaction
        tstart = tic;
        for itry = 1:300 % entspricht maximal 7 Minuten Verzögerung
        
        try
            datainsert(hConnection,tableName,cellArrayColumnsNames,data);
            if itry > 1
                % Einfügen hat funktioniert
                disp(['Verzögerung Schreiben ' num2str(toc(tstart)) 's after '  num2str(itry) ' trials'])
            end
            break;
        catch ME
            rollback(hConnection);
            if itry == 300
                error([getToolboxName() ': Maximum number of database write trials exceeded']);
            else
                if strcmp(ME.identifier,'database:database:insertExecuteError') || ...
                   strcmp(ME.identifier,'database:database:insertError')
                %disp(['t = ' num2str(toc(tstart)) ' - Datenbank ist vermutlich blockiert. Versuche es gleich nochmal.']);
                    pause(itry .* 10E-3);
                else
                    rethrow(ME)
                end
            end
            %
        end
        end

        %commit transaction
        tstart = tic;
        for itry = 1:300 % entspricht maximal 7 Minuten Verzögerung
        
            try
                commit(hConnection);
                if itry > 1
                    % Einfügen hat funktioniert
                    disp(['Verzögerung Commit ' num2str(toc(tstart)) 's after '  num2str(itry) ' trials'])
                end
                break;
            catch ME
                if itry == 300
                    error([getToolboxName() ': Maximum number of database commit trials exceeded']);
                else
                    if strcmp(ME.identifier,'database:database:commitFailure') 
                        pause(itry .* 10E-3);
                    else
                        rethrow(ME)
                    end
                end
                %
            end
        end        
    
    %set back original autocommit status
    try
        set(hConnection,'AutoCommit',savedAutoCommitgetStatus);
    catch
        success = 0;
    end   
    
    if success == 0
        warning('Failed somewhere in writing data');
    end
end

