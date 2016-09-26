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

function [ vars2set ] = getParamVariable2Set(labelstring,named_params,varargin)
%GETPARAMVARIABLE2SET Summary of this function goes here
%   Detailed explanation goes here

if named_params.NrParams == 0
    vars2set = cell(0,0);
    return;
end

[ blkpath, blkhdl ] = stoical.Label.Paths.l2p(labelstring,named_params.BlkHandle,varargin{:});

idx = find(ismember(named_params.BlkHandle,blkhdl));

%for param sets there may be several times the same block found -->
%discriminate furter
lstrparts = strsplit(labelstring,'#');
lastpart = ['^' lstrparts{end} '$'];

availableParams = named_params.ParamName(idx);

matches = ~cellfun(@isempty,regexp(availableParams,lastpart));

vars2set = named_params.ParamVariable(idx(matches));

end

