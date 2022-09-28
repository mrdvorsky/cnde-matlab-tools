function [out1, out2] = exampleFunction(stringIn, boolIn, optIn, options)
%EXAMPLEFUNCTION Example function showing documentation standards.
% Use this function as an example of how to document and use argument
% validation in your own functions.
%
% Example Usage:
%   out1 = exampleFunction("test1", true);
%   [out1, out2] = exampleFunction('test2', [0, true], 2, PositiveInt=1);
%   [out1, out2] = exampleFunction("a", false, StringArray=["1", "12"]);
%   [out1, out2] = exampleFunction("test3", 0, PositiveInt=-1); % Error
%   [out1, out2] = exampleFunction(0, 0);                       % Error
%   [out1, out2] = exampleFunction("a", "b");                   % Error
%   [out1, out2] = exampleFunction("a", false, StringArray=[]); % Error
%
% Include additional documentation here.
%
% Inputs:
%   stringIn - Scalar string input. List requirements here.
%   boolIn - Boolean input.
%   optIn (1) - Optional numeric input. List defaults in parentheses.
% Outputs:
%   out1 - First output argument. If all of boolIn are true, out1 is equal
%       to stringIn. Otherwise, it is equal to optIn.
%   out2 - Second output argument. If PositiveInt was assigned, out2 is
%       equal to PositiveInt. Otherwise, equal to StringArray.
%
% Named Arguments:
%   PositiveInt - Positive integer optional named argument. No default.
%   StringArray ("") - String array named optional argument. Default
%       value is an array with an empty string and should be listed in
%       parentheses.
%
% Author: Matt Dvorsky

arguments
    stringIn {mustBeTextScalar};            % Scalar String
    boolIn(:, 1) logical;                   % Vector of boolean values
    optIn(1, 1) {mustBeReal} = 1.0;         % Scalar real value
    options.PositiveInt(1, 1) {mustBeInteger, mustBePositive};
    options.StringArray(:, :, :) {mustBeText} = "";
end

%% Assign Output Values
if all(boolIn)
    out1 = optIn;
else
    out1 = stringIn;
end

if isfield(options, "PositiveInt")
    out2 = options.PositiveInt;
else
    out2 = options.StringArray;
end

end

