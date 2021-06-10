function [ ] = CalibrateSquareScanFull( filePath, offsetAngleDeg )
%CALIBRATESQUAREFULL Fully Calibrate Dual Pol Square Waveguide

arguments
    filePath;
    offsetAngleDeg(1, 1) string = "0";
end

%% Get File Names
[fileDirectory, fileName, ~] = fileparts(filePath);

%% Read Files
[X, Y, Z, F, Data, Header] = importScan(strcat(fullfile(...
    fileDirectory, fileName), ".scan"));
calFile = load(fullfile(fileDirectory, strcat(fileName, "/calData")));

%% Generate Rotation Matrix
A = [cosd(double(offsetAngleDeg)), -sind(double(offsetAngleDeg)); ...
    sind(double(offsetAngleDeg)), cosd(double(offsetAngleDeg))];

linToCirc = sqrt(0.5) * [1, 1j; 1, -1j];

%% Calibrate
DataLinear = permute(Data, [1, 2, 4, 5, 3]);
DataLinear = reshape(DataLinear, length(X), length(Y), length(F), 2, 2);
DataCircular = 0*DataLinear;
for xx = 1:size(DataLinear, 1)
    for yy = 1:size(DataLinear, 2)
        for ff = 1:size(DataLinear, 3)
            DataLinear(xx, yy, ff, :, :) = A * NPortCal(...
                squeeze(DataLinear(xx, yy, ff, :, :)), calFile.Tlin(:, :, :, ff)) * A.';
            DataCircular(xx, yy, ff, :, :) = linToCirc ...
                * squeeze(DataLinear(xx, yy, ff, :, :)) * linToCirc.';
        end
    end
end
DataLinear = reshape(DataLinear, length(X), length(Y), length(F), 4);

%% Save Calibrated Data
Header.channelNames = ["SHH", "SVH", "SHV", "SVV", "SLL", "SRL", "SLR", "SRR"];
Data = cat(4, DataLinear(:, :, :, :), DataCircular(:, :, :, :));
outFile = strcat(fileName, "_", "calibrated");
save(fullfile(fileDirectory, outFile), "Data", "X", "Y", "F", "Header");

end

