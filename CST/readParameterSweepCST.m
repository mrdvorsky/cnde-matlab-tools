function [ ] = readParameterSweepCST( foldername, varargin )
%READPARAMETERSWEEPCST Reads CST touchstone files and exports a .mat
%   Scans input folder for .s#p files and the corresponding parameter
%   files and reads in

%% Search for files of type .s#p
fileList = dir(fullfile(foldername, "*.s*p"));

SpTmp = readSnp(fullfile(fileList(1).folder, fileList(1).name));
F = SpTmp.Frequencies;

%% Read parameter files
for ii = 1:length(fileList)
    [~, basename, ~] = fileparts(fileList(ii).name);
    paramFile = strcat(basename, "-parameter.txt");
    
    paramText = fileread();
end

%% Read Data
Data = zeros(size(SpTmp.Parameters, 1), size(SpTmp.Parameters, 2), length(F), length(fileList));

end

