function [ ] = CalibrateSquareScanFullCircular( filePath )
%CALIBRATESQUAREFULL Fully Calibrate Dual Pol Square Waveguide

%% Get File Names
[fileDirectory, fileName, ~] = fileparts(filePath);

%% Read Files
[X, Y, Z, F, Data, Header] = importScan(strcat(fullfile(...
    fileDirectory, fileName), ".scan"));
calFile = load(fullfile(fileDirectory, strcat(fileName, "/calData")));

%% Calibrate
DataAll = permute(Data, [1, 2, 4, 5, 3]);
DataAll = reshape(DataAll, length(X), length(Y), length(F), 2, 2);
for xx = 1:size(DataAll, 1)
    for yy = 1:size(DataAll, 2)
        for ff = 1:size(DataAll, 3)
            DataAll(xx, yy, ff, :, :) = NPortCal(...
                squeeze(DataAll(xx, yy, ff, :, :)), calFile.Tcirc(:, :, :, ff));
        end
    end
end
DataAll = reshape(DataAll, length(X), length(Y), length(F), 4);

%% Save Calibrated Data
channelNames = ["SLL", "SRL", "SLR", "SRR"];
for ii = 1:length(channelNames)
    Data = DataAll(:, :, :, ii, 1);
    outFile = strcat(fileName, "_", channelNames(ii));
    save(fullfile(fileDirectory, outFile), "Data", "X", "Y", "F", "Header");
end

end

