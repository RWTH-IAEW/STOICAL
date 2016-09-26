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

function [hConnection] = sqlite3_connect(dbpath, jdbcpath)

    % Set this to the location of the sqlitehdbc jar file.
    %SQLITE_JDBC_JAR = [getenv('HOME') filesep 'contrib/sqlitejdbc-v056.jar'];
    %SQLITE_JDBC_JAR = [getenv('HOME') filesep 'sqlite-jdbc-3.7.2.jar'];
    SQLITE_JDBC_JAR = jdbcpath;

    % Put the sqlite jdbc jar in the Matlab classpath.
    if ~any(strcmp(SQLITE_JDBC_JAR, javaclasspath))
        javaaddpath(SQLITE_JDBC_JAR);
    end

    hConnection = database('', '', '', 'org.sqlite.JDBC', ['jdbc:sqlite:' dbpath]);

    %do some stupid query in order to accelerate the next real querry up to
    % 10..100 times
    if isconnection(hConnection)
        res = sqlite3_query(hConnection, ...
                                ['CREATE TABLE tmp_logforsqlite2matlabconnector (a); ' ...
                                 'SELECT COUNT(*) FROM tmp_logforsqlite2matlabconnector; ' ...
                                 'DROP TABLE tmp_logforsqlite2matlabconnector']);
    end

end