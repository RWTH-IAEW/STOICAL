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

function [ BlkHandle, notfound, BlkPath ] = getUpdatedBlkHandles( BlkPath )
%GETUPDATEDBLKHANDLES Summary of this function goes here
%   Detailed explanation goes here

    notfound  = false(size(BlkPath,1),1);

    if isempty(BlkPath)
        BlkHandle = [];
        notfound  = true;
        return;
    end
    
    %avoid rename model file problem:
    StrParts = cellfun(@(x) strsplit(x,'/','CollapseDelimiters',false),BlkPath,'UniformOutput',false);
    BlkPath  = cellfun(@(x) strjoin([{bdroot} x(2:end)],'/'),StrParts,'UniformOutput',false);
    
    try
        Handles = get_param(BlkPath,'Handle');
    catch
        Handles = cell(size(BlkPath,1),1);
        
        for iBlk = 1:size(BlkPath,1)
            try
                Handles{iBlk,1} = get_param(BlkPath{iBlk,1},'Handle');
            catch
                Handles{iBlk,1} = -1;
                notfound(iBlk,1) = true;
            end
        end
    end
    
    if isempty(Handles)
        BlkHandle = ones(size(BlkPath,1),0);
        notfound  = true(size(BlkPath,1),1);
        return;
    end
    
    BlkHandle = ones(size(BlkPath,1),1) .* -1;
    
    if iscell(Handles)
        notfoundhere = cellfun(@isempty,Handles);
        notfound = notfound | notfoundhere;
        BlkHandle(~notfoundhere) = cell2mat(Handles);
    else
        BlkHandle = Handles;
    end
    
end

