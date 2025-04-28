function [] = cndeMatlabUtils_startup(options)
%Function that is run at Matlab startup.
% 
% Author: Matt Dvorsky

arguments
    options.CheckForUpdates(1, 1) logical = true;
end

%% Add to Path
addpath(fullfile(userpath(), "cnde-matlab-utils", "install"));
addpath(genpath(fullfile(userpath(), "cnde-matlab-utils", "source")));

end

