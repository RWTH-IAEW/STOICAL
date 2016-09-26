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

function [Result] = sqlite3_batchquery(hConnection, query, varargin)

assert(mod(length(varargin), 2) == 0, 'Additional arguments to sqlite3_query must come in pairs.');

for ii = 1:2:length(varargin)
    if isnumeric(varargin{ii+1})
        value = num2str(varargin{ii+1});
    else
        value = varargin{ii+1};
    end
    query = strrep(query, ['{' varargin{ii} '}'], value);
end

Result = [];

%setdbprefs('DataReturnFormat','numeric');
setdbprefs('DataReturnFormat','cellarray');

cursor = exec(hConnection, query);

fetchsize = 1E5;
fetchsize = 10*floor(fetchsize / 10);

%mache durch 2 teilbar

fetchNr = 1;
tryagain = 0;

while ~strcmp(cursor.Data, 'No Data')
    try
        cursor = fetch(cursor,fetchsize);
        Result = [Result;cursor.Data];
        if fetchNr == 1 && strcmp(cursor.Data, 'No Data')
            %no data found
            Result = [];
            return;
        end
    catch
        %Prüfe warum ein Fehler auftrat.
        % Ist die Abfrage Fertig ?
        if (size(cursor.Data,1) > 1) && (size(cursor.Data,1) < fetchsize)
            break
        elseif (size(cursor.Data,1) == 1) && (size(cursor.Data,2) > 0) && (size(cursor.Data,1) < fetchsize)
            break
        else
            tryagain = 1;
            
            fetchsize = fetchsize / 10;
            fetchsize = 10*floor(fetchsize / 10);
            if fetchsize == 0
                fetchsize = 1;
            end
        end
    end
    %disp(fetchNr);
    fetchNr = fetchNr + 1;
    if (tryagain == 0) && (size(cursor.Data,1) == 1) && (size(cursor.Data,2) == 1) && ~iscell(cursor.Data) && (cursor.Data == 0)
        break;
    end
end

end
