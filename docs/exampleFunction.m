function [out1, out2] = exampleFunction(stringIn, boolIn, optIn, options)
%Example function showing documentation standards.
% Use this function as an example of how to document and use argument
% validation in your own functions. This function in particular checks that
% the first argument,
%
% Example Usage:
%   [out1] = exampleFunction("test1", true);
%   [out1, out2] = exampleFunction('test2', [0, true], 2, PositiveOddInt=1);
%   [out1, out2] = exampleFunction("a", false, StringArray=["1", "12"]);
%   [out1, out2] = exampleFunction("test3", 0, PositiveOddInt=-1);  % Error
%   [out1, out2] = exampleFunction("test3", 0, PositiveOddInt=4);   % Error
%   [out1, out2] = exampleFunction(0, 0);                           % Error
%   [out1, out2] = exampleFunction("a", "b");                       % Error
%
%
% Include additional documentation here.
%
% Inputs:
%   stringIn - Scalar string input. List requirements here.
%   boolIn - Vector of boolean inputs.
%   optIn (1) - Optional numeric input. List defaults in parentheses.
%
% Outputs:
%   out1 - First output argument. If all of boolIn are true, out1 is equal
%       to stringIn. Otherwise, it is equal to optIn.
%   out2 - Second output argument. If PositiveOddInt was assigned, out2 is
%       equal to PositiveOddInt. Otherwise, equal to StringArray.
%
% Named Arguments: (Always capitalize first letter for named arguments)
%   PositiveOddInt - Positive odd integer optional named argument. No default.
%   StringArray ("") - String array named optional argument. Default
%       value is an array with an empty string and should be listed in
%       parentheses.
%
% Author: Matt Dvorsky

arguments
    stringIn(1, 1) string;                  % Scalar String
    boolIn(:, 1) logical;                   % Vector of boolean values
    optIn(1, 1) {mustBeReal} = 1.0;         % Scalar real value

    options.PositiveOddInt(1, 1) {mustBePositiveOddInteger};    % Custom validation defined below
    options.StringArray(:, :, :) string = "";
end

%% Assign Output Values
if all(boolIn)
    out1 = stringIn;
else
    out1 = optIn;
end

if isfield(options, "PositiveOddInt")
    out2 = options.PositiveOddInt;
else
    out2 = options.StringArray;
end

end



%% Custom Argument Validation Function
% Always indent the extra functions at the end of a file.
function mustBePositiveOddInteger(num)
    mustBeInteger(num);
    mustBePositive(num);
    if mod(num, 2) ~= 1
        throwAsCaller(MException("CNDE:mustBePositiveOddInteger", ...
            "Value must be a positive odd integer."));
    end
end

