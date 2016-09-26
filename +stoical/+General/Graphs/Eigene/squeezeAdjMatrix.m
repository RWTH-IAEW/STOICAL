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

function [ squeezedA, newnodeoldnodeidx ] = squeezeAdjMatrix( A )
%SQUEEZEADJMATRIX Summary of this function goes here
%   Detailed explanation goes here

AdjMatrix = A;

colSum = sum(AdjMatrix ~= 0,1);
rowSum = sum(transpose(AdjMatrix) ~= 0,1);
totSum = colSum + rowSum;
filt_del = totSum == 0;

tmp1cutAdjMatrix = AdjMatrix;
tmp1cutAdjMatrix(:,filt_del) = [];
tmp2cutAdjMatrix = transpose(tmp1cutAdjMatrix);
tmp2cutAdjMatrix(:,filt_del) = [];

squeezedA = transpose(tmp2cutAdjMatrix);

newnodeoldnodeidx = find(~filt_del);

end

