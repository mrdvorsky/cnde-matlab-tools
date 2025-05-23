function mustHaveAtLeastOneRepeatingArg(Arrays)
%Validate that the input cell array (for Repeating input) is nonempty.
% Throws an error if the input cell array is empty. Due to the error
% message, this validator is suitable for when you have a repeating
% argument block that for which you want to have at least one argument.
%
% Example Usage:
%   arguments (Repeating)
%       Arrays;
%   end
%   mustHaveAtLeastOneRepeatingArg(Arrays);     % Throws error if no input arguments.
%
% Author: Matt Dvorsky

arguments
    Arrays;
end

%% Check Input Size
if ~isempty(Arrays)
    return;
end
throwAsCaller(MException("MATLAB:narginchk:notEnoughInputs", ...
    "Must have at least one argument."));

end

