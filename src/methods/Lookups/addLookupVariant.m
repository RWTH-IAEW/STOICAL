function [ STOVICAL_Lookup ] = addLookupVariant( LabelPath2Set, Values, STOVICAL_Lookup )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
%   
%   no error checking here --> cheap and fast

%% Catch initial situation
    if nargin < 3
        STOVICAL_Lookup = struct();
        STOVICAL_Lookup.Variant = struct();
        STOVICAL_Lookup.Variant.LabelPath = cell(1,0);
        STOVICAL_Lookup.Variant.Values    = cell(1,0);
    end
    
    if nargin == 3
        if ~isfield(STOVICAL_Lookup,'Variant')
            STOVICAL_Lookup.Variant = struct();
        end
        if ~isfield(STOVICAL_Lookup.Variant,'LabelPath')
            STOVICAL_Lookup.Variant.LabelPath = cell(1,0);
        end
        if ~isfield(STOVICAL_Lookup.Variant,'Values')
            STOVICAL_Lookup.Variant.Values = cell(1,0);
        end
    end            
    
%% Check if there are values to override
    %TODO
    %now: append on default
    
%% Add of Values, Convert 2 String
    STOVICAL_Lookup.Variant.LabelPath{1,end+1} = LabelPath2Set;
    
    if ischar(Values)
        tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
        tmp(:) = {Values};
        STOVICAL_Lookup.Variant.Values{   1,end+1} = tmp;
    elseif iscell(Values)
        if length(Values) == 1 & STOVICAL_Lookup.NrOfExperiments > 1
            tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
            tmp(:) = Values;
            Values = tmp;
        end
        STOVICAL_Lookup.Variant.Values{   1,end+1} = Values;
    else
        if isnumeric(Values)
            if length(Values) == 1 & STOVICAL_Lookup.NrOfExperiments > 1
                tmp = cell(1,STOVICAL_Lookup.NrOfExperiments);
                tmp(:) = {Values};
                Values = tmp;
                STOVICAL_Lookup.Variant.Values{   1,end+1} = Values;
            else
                Values = num2cell(Values);
                STOVICAL_Lookup.Variant.Values{   1,end+1} = Values;
            end 
        end
    end    
    
end

