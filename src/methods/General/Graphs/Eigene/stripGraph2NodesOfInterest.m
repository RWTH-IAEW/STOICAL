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

function [ stripedGraph ] = stripGraph2NodesOfInterest( A, startNode, targetnodes, targetnodesonly, nodes2keepiffound )
%STRIPGRAPH2NODESOFINTEREST Summary of this function goes here
%   Detailed explanation goes here

    %merker für die zu ber. knoten
        nodes2considervec = zeros(1,size(A,2));
        
    AwithAddConn = A;

    targetnodes = unique(reshape(targetnodes,[],1)); % Vektor sicherstellen
    nodes2keepiffound = unique(reshape(nodes2keepiffound,[],1));
    
    %Erzeuge BiographObject
    orig_BGObj = biograph(A);
    
    for itarg = 1:length(targetnodes) % alle zielknoten durchlaufen
        
        [~, p, ~ ] = shortestpath(orig_BGObj,startNode,targetnodes(itarg));

        %welche knoten sind keine targetnodes oder der Startknoten?
        [other_nodes_in_p,other_nodes_in_p_idx] = setdiff(p,[startNode;targetnodes]);
        
        %welche der knoten sind zwar keine dieser Knoten, aber nodes2keepiffound ?
        [is_nodes2keepiffound] = ismember(other_nodes_in_p,nodes2keepiffound);
        other_nodes_in_p_idx(is_nodes2keepiffound) = [];

        pwithout = p; 
        pwithout(other_nodes_in_p_idx) = [];
        
        %füge eine Verbindung in A ein, wenn Zwischenknoten auf dem Pfad
        %liegen
        newedges = path2edges(pwithout);
        if ~isempty(newedges)
            idx = sub2ind(size(AwithAddConn),newedges(:,1),newedges(:,2));
            AwithAddConn(idx) = 1;
        end
        
        %merke die knoten auf dem Pfad
        if targetnodesonly
            nodes2considervec(1,pwithout) = 1;
        else
            % auch solche, die oben unter
            %targetnode nicht definiert wurden !!!!                
            nodes2considervec(1,p) = 1;
        end
    end

    % Erzeuge einen neuen Graphen nur mit den gemerkten Knoten
        if targetnodesonly
            Astriped = AwithAddConn;
        else
            Astriped = A;
        end
        Astriped(nodes2considervec==0,:) = 0;
        Astriped(:,nodes2considervec==0) = 0;

        stripedGraph = Astriped;
        
end

