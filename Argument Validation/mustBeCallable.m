function [] = mustBeCallable(fun, funArgs, callArgString)
%MUSTBECALLABLE Validate that value is callable with given arguments.
% Throws an error if "fun" is not able to be called with the arguments
% given by the cell array "funArgs". In other words, the function call
% "fun(funArgs{1}, funArgs{2}, ...)" should not throw an error. If it does
% throw an error, the user will be displayed a message that
% "fun(*callArgString*)" should be valid, where "callArgString" is an
% optional string that can be passed in.
%
% Example Usage:
%   arguments
%       ...
%       inputFun(1, 1) {mustBeCallable(inputFun, {0}, "num")};
%       inputFunArray(:, 1) {mustBeCallable(inputFunArray, ...
%                               {"test", 1, 0}, "inputStr, num1, num2")};
%       ...
%   end
%
% Author: Matt Dvorsky

arguments
    fun;
    funArgs(:, 1) {mustBeA(funArgs, "cell")};
    callArgString {mustBeTextScalar} = "";
end

%% Check Argument
try
    fun(funArgs{:});
catch ex
    if strcmp(callArgString, "")
        callArgString = strjoin(compose("arg%d", 1:numel(funArgs)), ", ");
    end
    throwAsCaller(MException("MATLAB:mustBeCallable", ...
        sprintf("Argument must be callable with (%d) arguments, " + ...
        "i.e., it should be callable as 'fun(%s)'. However, " + ...
        "when called, the function threw the following error: '%s'", ...
        numel(funArgs), callArgString, ex.message)));
end

end

