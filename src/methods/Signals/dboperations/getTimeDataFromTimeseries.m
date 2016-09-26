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

function [ Time, Data ] = getTimeDataFromTimeseries( ts, FixedStepTimeWindow )
%GETTIMEDATAFROMTIMESERIES Summary of this function goes here
%   Detailed explanation goes here

    %%
    if nargin < 2
        douseTimeWindow = false;
    else
        douseTimeWindow = true;
    end

    %%
    Time = ts.Time;
    Data = ts.Data;

    if douseTimeWindow
        % create times 2 consider & save
            Tmin  = max([FixedStepTimeWindow(1),0]); % avoid negative entries
            Tmax  = min([FixedStepTimeWindow(2),Time(end)]); %Window may be Inf-terminated
            Tstep = FixedStepTimeWindow(3);

            relevT = Tmin:Tstep:Tmax;
        
        % may be slow
        % may be problematic if small numerical error are introduced in the
        % times -> rounding?
        %    filt = ismember(Time,relevT); % possible intermediate values are discarded
        
        [~,idxmin] = min(abs(Time-Tmin));
        [~,idxmax] = min(abs(Time-Tmax));
        
        if length(idxmin:idxmax) ~= length(relevT)
            disp([getToolboxName() ': Fixed Step Signal Time and Data stamps not matching']);
            idxmax = idxmin + length(relevT) - 1;
        end
        
        Time = Time(idxmin:idxmax,:);
        Data = Data(idxmin:idxmax,:);
    end

end

