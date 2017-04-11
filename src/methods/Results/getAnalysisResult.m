function [ ResultData ] = getAnalysisResult( LabelPath2Get, STOVICAL_Results )
%GETANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

%% Identify Values to Return
%  make this more sophisticated!
    filt_found = ismember(STOVICAL_Results.LabelPath,LabelPath2Get);
    
%% Return of Values
    if sum(filt_found) > 1
        ResultData = STOVICAL_Results.Values(filt_found); %return as cell
    elseif sum(filt_found) == 1
        ResultData = STOVICAL_Results.Values{filt_found}; %return as whatever is inside cell
    else
        ResultData = []; % return empty structure
        warning([getToolboxName() ': Desired Results not found: "' LabelPath2Get '"']);
    end
    
%% Handle empty cellentries
    if iscell(ResultData)
        find_empty = cellfun('isempty',ResultData);
        
        if any(find_empty) && any(~find_empty)
            idx_nonempty = find(~find_empty,1,'first');
            if isnumeric(ResultData{idx_nonempty})
                ResultData(find_empty) = {ResultData{idx_nonempty}.*nan};
            else
                warning([getToolboxName() ': empty results found. Take care of cell2mat!']);
            end
        end
    end

end

