function [ STOVICAL_Lookup ] = delLookupExperiments( Experiments2Delete, STOVICAL_Lookup )
%ADDANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here
%   
%   no error checking here --> cheap and fast

%% Check if anything to delete

    if isempty(Experiments2Delete)
        return;
    end

    if islogical(Experiments2Delete)
        if length(Experiments2Delete) ~= STOVICAL_Lookup.NrOfExperiments
            error('Wrong size of delete filter');
        end
        if ~any(Experiments2Delete)
            return;
        end
    end
    
    if isnumeric(Experiments2Delete)
        tmp_filt = false(1,STOVICAL_Lookup.NrOfExperiments);
        tmp_filt(Experiments2Delete) = true;
        Experiments2Delete = tmp_filt;
    end
    
%% Catch initial situation
    if isfield(STOVICAL_Lookup,'Variant')
        hasVariants = true;
    else
        hasVariants = false;
    end
    
    if isfield(STOVICAL_Lookup,'Parameter')
        hasParameters = true;
    else
        hasParameters = false;
    end
    
%% Delete Experiments
    if hasVariants
        STOVICAL_Lookup.Variant.Values = ...
            cellfun(@(x) x(~Experiments2Delete),STOVICAL_Lookup.Variant.Values,'UniformOutput',false);
    end
    
    if hasParameters
        STOVICAL_Lookup.Parameter.Values = ...
            cellfun(@(x) x(~Experiments2Delete),STOVICAL_Lookup.Parameter.Values,'UniformOutput',false);
    end
    
    STOVICAL_Lookup.NrOfExperiments = sum(~Experiments2Delete);
    
end

