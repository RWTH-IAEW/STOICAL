function [ ResultData ] = getLookupVariant( LabelPath2Get, STOVICAL_Lookup )
%GETANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

%% Identify Values to Return
%  make this more sophisticated!
    filt_found = ismember(STOVICAL_Lookup.Variant.LabelPath,LabelPath2Get);
    
%% Return of Values
    if sum(filt_found) > 1
        ResultData = STOVICAL_Lookup.Variant.Values(filt_found); %return as cell
    elseif sum(filt_found) == 1
        ResultData = STOVICAL_Lookup.Variant.Values{filt_found}; %return as whatever is inside cell
    else
        ResultData = []; % return empty structure
        warning([getToolboxName() ': Desired Variant Lookup not found: "' LabelPath2Get '"']);
    end

end

