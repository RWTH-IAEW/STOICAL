function [ ResultData ] = getLookupParameter( LabelPath2Get, STOVICAL_Lookup )
%GETANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

%% Identify Values to Return
%  make this more sophisticated!
    filt_found = ismember(STOVICAL_Lookup.Parameter.LabelPath,LabelPath2Get);
    
%% Return of Values
    if sum(filt_found) > 1
        ResultData = STOVICAL_Lookup.Parameter.Values(filt_found); %return as cell
    elseif sum(filt_found) == 1
        ResultData = STOVICAL_Lookup.Parameter.Values{filt_found}; %return as whatever is inside cell
    else
        ResultData = []; % return empty structure
        warning([getToolboxName() ': Desired Parameter Lookup not found: "' LabelPath2Get '"']);
    end

end

