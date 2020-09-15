function [ ] = CalibrateSquareScanFullLinear( filePath, offsetAngleDeg )
%CALIBRATESQUAREFULL Fully Calibrate Dual Pol Square Waveguide

%% Inputs
if nargin < 2
    offsetAngleDeg = 0;
end

%% Get File Names
[fileDirectory, fileName, ~] = fileparts(filePath);

%% Read Files
[X, Y, Z, F, Data, Header] = importScan(strcat(fullfile(...
    fileDirectory, fileName), ".scan"));
calFile = load(fullfile(fileDirectory, strcat(fileName, "/calData")));

%% Generate Rotation Matrix
A = [cosd(offsetAngleDeg), -sind(offsetAngleDeg); ...
    sind(offsetAngleDeg), cosd(offsetAngleDeg)];

%% Calibrate
DataAll = permute(Data, [1, 2, 4, 5, 3]);
DataAll = reshape(DataAll, length(X), length(Y), length(F), 2, 2);
for xx = 1:size(DataAll, 1)
    for yy = 1:size(DataAll, 2)
        for ff = 1:size(DataAll, 3)
            DataAll(xx, yy, ff, :, :) = A * NPortCal(...
                squeeze(DataAll(xx, yy, ff, :, :)), calFile.Tlin(:, :, :, ff)) * A.';
        end
    end
end
DataAll = reshape(DataAll, length(X), length(Y), length(F), 4);

%% Save Calibrated Data
channelNames = ["SVV", "SHV", "SVH", "SHH"];
for ii = 1:length(channelNames)
    Data = DataAll(:, :, :, ii, 1);
    outFile = strcat(fileName, "_", channelNames(ii));
    save(fullfile(fileDirectory, outFile), "Data", "X", "Y", "F", "Header");
end

end

