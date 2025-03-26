clc;
clear;
close all;

%% Inputs
concatenatedContent = "";

dirTmp = dir();
folders = string({dirTmp([dirTmp.isdir]).name});
folders = folders(4:end);

for ff = 1:numel(folders)
    fileList = dir(fullfile(folders(ff), "*.m"));
    for ii = 1:length(fileList)
        filename = fileList(ii).name;
        fileContent = fileread(filename);

        concatenatedContent = strcat(concatenatedContent, ...
            newline, ...
            fileContent, newline);
    end
end

% Display the concatenated content
clipboard("copy", concatenatedContent);

