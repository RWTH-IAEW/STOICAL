function [] = listAnalysisResults( STOVICAL_Results, LookForRegExp )
%GETANALYSISRESULT Summary of this function goes here
%   Detailed explanation goes here

Defined_Res_Labels = STOVICAL_Results.LabelPath;


%% separate all entries
list = sort(reshape(Defined_Res_Labels,[],1));

if nargin == 2
    filt = ~cellfun(@isempty,regexp(list,LookForRegExp));
else
    filt = true(size(Defined_Res_Labels));
end

%tablist = regexprep(list(filt),'#','\t');
tablist = list(filt);

for i = 1:length(tablist);
    fprintf('%s\n',tablist{i});
end

end

