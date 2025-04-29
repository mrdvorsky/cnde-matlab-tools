function [] = cndeMatlabTools_checkForUpdates(options)
%This function "updates" the cnde-matlab-tools library.
% Essentially, this function does the following:
%   - Fetch latest from remote git repo.
%   - Check if there is an update.
%   - If there is an update, ask the user if they want to update.
%       - If user has modified libary, ask if they want to revert.
%
% Author: Matt Dvorsky

arguments
    options.AlwaysShowPopupWindow(1, 1) logical = true;
end

%% Inputs and Paths
% The line below will be dynamically replaced on install.
libPath = "<LIBRARY_PATH>";
if contains(libPath, "<") && contains(libPath, ">")
    error("String replacement was not completed.");
end

[~, libName] = fileparts(libPath);
updaterTitle = sprintf("'%s' Updater", libName);

%% Look for Git Repo
repo = gitrepo(libPath);
fetch(repo);

isThereAnUpdate = false;
if ~isThereAnUpdate
    if options.AlwaysShowPopupWindow
        msgbox(sprintf("'%s' libary is up to date (%s).", ...
            libName, cndeMatlabTools_getVersion()), ...
            updaterTitle);
    end
    return;
end

%% Popup Window
resp = questdlg(sprintf(...
    "'%s' library has updates. Do you want to update?", ...
    libName), ...
    updaterTitle, ...
    "Update", "Cancel", "Update");

if strcmp(resp, "Update")
    fprintf("Test\r\n");
end

end

