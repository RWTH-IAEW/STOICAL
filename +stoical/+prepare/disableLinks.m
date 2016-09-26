function disableLinks(STOICAL_MODEL, whitelist)
links = libinfo(STOICAL_MODEL);

for ii = 1:length(links);
    if any(strcmp(links(ii).Library, whitelist))
        if strcmp(links(ii).LinkStatus, 'resolved')
            set_param(links(ii).Block, 'LinkStatus', 'inactive');
        end
    end
end
