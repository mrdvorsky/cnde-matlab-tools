function [ ] = CalibrateScanFromShort(filePath, calAppend, shortChannel)
%CALIBRATEFROMSHORT Creates a calibrated .mat file from a .scan and a
%   .s2p file

%% Cal File Extension
if nargin < 3
    shortChannel = [1, 1];
end
if nargin < 2
    calAppend = "";
end

%% Get File Names
[fileDirectory, fileName, ~] = fileparts(filePath);

%% Read Files
try
    [X, Y, Z, F, Data, Header] = importScan(strcat(fullfile(...
        fileDirectory, fileName), ".scan"));
catch
    error("File '%s.scan' does not exist.", fullfile(fileDirectory, fileName));
end

try
    cal = readSnp(strcat(fullfile(fileDirectory, ...
        strcat(fileName, calAppend)), ".s2p"));
    calData = cal.Parameters(shortChannel(1), shortChannel(2), :);
catch
    error("File '%s.s2p' does not exist or has the wrong format.", fullfile(fileDirectory, fileName));
end

%% Calibrate
DataAll = permute(Data, [1, 2, 4, 5, 3]) ./ exp(1j .* angle(calData));

%% Save Calibrated Data
for ii = 1:size(DataAll, 4)
    Data = DataAll(:, :, :, ii, 1);
    outFile = strcat(fileName, "_", Header.channelNames(ii));
    save(fullfile(fileDirectory, outFile), "Data", "X", "Y", "F", "Header");
end

