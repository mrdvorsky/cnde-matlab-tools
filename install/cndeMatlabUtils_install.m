function [] = cndeMatlabUtils_install()
%This function "installs" the cnde-matlab-utils library.
% Essentially, this function does the following:
%   - Creates the "startup.m" file in the userpath directory, if it does
%       not already exist.
%   - Adds the line "cndeMatlabUtils_startup(...);" to the "startup.m"
%       file, if it does not already exist.
%   - Copies "cndeMatlabUtils_startup.m" to the userpath directory.
%   - Runs the "cndeMatlabUtils_startup" function.
%
% Author: Matt Dvorsky

%% Check if "startup.m" Exists at UserPath
startupFilePath = fullfile(userpath(), "startup.m");
startupFileInfo = dir(startupFilePath);
if isempty(startupFileInfo)
    % Create empty file.
    fid = fopen(startupFilePath, "w");
    fclose(fid);
end

% "startup.m" exists. Search for "cndeMatlabUtils_startup(...);"
startupFileTextLines = readlines(startupFilePath);
isStartupLine = startsWith(startupFileTextLines, ...
    "cndeMatlabUtils_startup(");

lineDoesNotExist = ~any(isStartupLine);
if lineDoesNotExist
    writelines("cndeMatlabUtils_startup(CheckForUpdates=true);", ...
        startupFilePath, ...
        WriteMode="append");
end

%% Copy "cndeMatlabUtils_startup.m" to userpath Folder
libStartupFile = fullfile(userpath(), ...
    "cnde-matlab-utils", "install", ...
    "cndeMatlabUtils_startup.m");
copyfile(libStartupFile, userpath());

%% Run Startup
cndeMatlabUtils_startup(CheckForUpdates=true);

%% Finished Dialogue
msgbox("Library 'cnde-matlab-utils' was successfully installed.", ...
    "Install 'cnde-matlab-utils'");

end

