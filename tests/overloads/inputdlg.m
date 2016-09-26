function [ result ] = inputdlg(~, ~, ~, ~, ~, injectedAnswer )
persistent ANSWER
if nargin > 5
    ANSWER = injectedAnswer;
else
    result = ANSWER;
end
end

