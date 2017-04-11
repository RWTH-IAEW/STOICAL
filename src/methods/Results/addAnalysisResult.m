function [ STOVICAL_Results ] = addAnalysisResult( LabelPath2Set, Values, STOVICAL_Results )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

checkNeed2Overwrite = true;

%% Catch initial situation
    if nargin < 3
        STOVICAL_Results = struct();
        STOVICAL_Results.LabelPath = cell(1,0);
        STOVICAL_Results.Values    = cell(1,0);
        
        checkNeed2Overwrite = false;
    end
    
    if nargin == 3 
        if ~isfield(STOVICAL_Results,'LabelPath')
            STOVICAL_Results.LabelPath = cell(1,0);
            checkNeed2Overwrite = false;
        end
        if ~isfield(STOVICAL_Results,'Values')
            STOVICAL_Results.Values = cell(1,0);
            checkNeed2Overwrite = false;
        end
    end            
    
%% Check if there are values to override
    if checkNeed2Overwrite
        IDX = find(ismember(STOVICAL_Results.LabelPath,LabelPath2Set),1,'last');
        if isempty(IDX)
            IDX = size(STOVICAL_Results.LabelPath,2)+1;
        end
    else
        IDX = size(STOVICAL_Results.LabelPath,2)+1;
    end    
    
%% Add / Replacement of Values
    STOVICAL_Results.LabelPath{1,IDX} = LabelPath2Set;
    STOVICAL_Results.Values{   1,IDX} = Values;
    
end

