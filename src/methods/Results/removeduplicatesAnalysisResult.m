function [ STOVICAL_Results ] = removeduplicatesAnalysisResult( LabelPath2Set, STOVICAL_Results, varargin )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
    
%%
    p = inputParser;
    
    validate_keep = @(x) ismember(x,{'last','first'});
    
    addRequired(p,'keep',validate_keep);
    %parse(p,LabelPath2Set,STOVICAL_Results,varargin{:});
    parse(p,varargin{:});

%% Check if there are values to override
    IDX_dupl = find(ismember(STOVICAL_Results.LabelPath,LabelPath2Set));
    if isempty(IDX_dupl)
        return;
    end
    
    IDX_keep = find(ismember(STOVICAL_Results.LabelPath,LabelPath2Set),1,p.Results.keep);
    
    IDX_kill = setdiff(IDX_dupl,IDX_keep);
    if isempty(IDX_kill)
        return;
    end
    
%% Add / Replacement of Values
    STOVICAL_Results.LabelPath(IDX_kill) = [];
    STOVICAL_Results.Values(   IDX_kill) = [];
    
end

