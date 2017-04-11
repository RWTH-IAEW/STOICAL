function [ STOVICAL_Lookup ] = addLookupParameter( LabelPath2Set, Values, STOVICAL_Lookup )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
%   
%   no error checking here --> cheap and fast

%% Catch initial situation
    if nargin < 3
        STOVICAL_Lookup = struct();
        STOVICAL_Lookup.Parameter = struct();
        STOVICAL_Lookup.Parameter.LabelPath = cell(1,0);
        STOVICAL_Lookup.Parameter.Values    = cell(1,0);
    end
    
    if nargin == 3
        if ~isfield(STOVICAL_Lookup,'Parameter')
            STOVICAL_Lookup.Parameter = struct();
        end
        if ~isfield(STOVICAL_Lookup.Parameter,'LabelPath')
            STOVICAL_Lookup.Parameter.LabelPath = cell(1,0);
        end
        if ~isfield(STOVICAL_Lookup.Parameter,'Values')
            STOVICAL_Lookup.Parameter.Values = cell(1,0);
        end
    end            
    
%% Check if there are values to override
    %TODO
    %now: append on default
    
%% Add of Values, Convert 2 String
    STOVICAL_Lookup.Parameter.LabelPath{1,end+1} = LabelPath2Set;
    
    if isnumeric(Values)
        if length(Values) == 1
            Values = ones(1,STOVICAL_Lookup.NrOfExperiments).*Values;
        end
        % do not convert 2 string here !!!
            %tmp = num2cell(Values);
            %tmp = cellfun(@num2str,tmp,'UniformOutput',false);
        STOVICAL_Lookup.Parameter.Values{   1,end+1} = Values; %tmp
    elseif ischar(Values)
        tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
        tmp(:) = {Values};
        STOVICAL_Lookup.Parameter.Values{   1,end+1} = tmp;
    elseif iscell(Values)
        if length(Values) == 1 & STOVICAL_Lookup.NrOfExperiments > 1
            tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
            tmp(:) = {Values};
            Values = tmp;
        end
        STOVICAL_Lookup.Parameter.Values{   1,end+1} = Values;
    end
    
end

