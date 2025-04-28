function [] = cndeMatlabUtils_uninstall()
%This function "uninstalls" the cnde-matlab-utils library.
% Essentially, this function does the following:
%   - Removes the line "cndeMatlabUtils_startup(...)" from the
%       "startup.m" file, if the line is present.
%   - Deletes the "cndeMatlabUtils_startup.m" file, if it exists.
%   - Remove library folders from path.
%
% Author: Matt Dvorsky

%% Check if "startup.m" Exists at UserPath
startupFilePath = fullfile(userpath(), "startup.m");
startupFileInfo = dir(startupFilePath);
if ~isempty(startupFileInfo)
    % "startup.m" exists. Search for "cndeMatlabUtils_startup(...);"
    startupFileTextLines = readlines(startupFilePath);
    isStartupLine = startsWith(startupFileTextLines, ...
        "cndeMatlabUtils_startup(");

    lineDoesNotExist = ~any(isStartupLine);
    if lineDoesNotExist
        warning("Line 'cndeMatlabUtils_startup(...);' does not exist in 'startup.m'");
    else
        writelines(startupFileTextLines(~isStartupLine), ...
            startupFilePath, ...
            WriteMode="overwrite");
    end
end

%% Delete the "cndeMatlabUtils_startup.m" Function
delete(fullfile(userpath(), "cndeMatlabUtils_startup.m"));

%% Remove Folders from Path
rmpath(genpath(fullfile(userpath(), "cnde-matlab-utils", "source")));
rmpath(fullfile(userpath(), "cnde-matlab-utils", "install"));

%% Popup Window
% resp = questdlg("Library 'cnde-matlab-utils' was successfully uninstalled. " + ...
%     "The git repository", ...
%     "Uninstall 'cnde-matlab-utils'", ...
%     "Yes", "No", "No");
% 
% if strcmp(resp, "Yes")
%     rmdir(fullfile(userpath());
% end

end

