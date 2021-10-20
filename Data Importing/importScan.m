function [X, Y, Z, F, Data, Header] = importScan(filenameIn)
%IMPORTSCAN Import a ".scan" file created by the amntl scanner program.
% This function imports and parses a ".scan" file.
%
% Example Usage:
%   [X, Y, Z, F, Data, Header] = importScan(filename);
%
% Inputs:
%   filenameIn - Path to the file. If the file has no extension, ".scan"
%       will be automatically appended.
% Output:
%   X, Y, Z, ... - Vectors containing the coordinates of each scan point.
%       If the scan is uniform, each vector will contain a unique, sorted,
%       and uniformly increasing list of coordinates for the corresponding
%       dimension. Otherwise, each vector will contain one element for each
%       scan point.
%
% Author: Matt Dvorsky

%% Open File
% Add ".scan" extension if filenameIn has no extension.
[path, name, ext] = fileparts(filenameIn);
if (ext == "")
    filename = fullfile(path, strcat(name, ".scan"));
else
    filename = filenameIn;
end

fileHandle = fopen(filename);
if fileHandle == -1
    error("File ('%s') not found.", filename);
end

%% Get Version Info
scanFileCode = fread(fileHandle, 1, 'double');
if scanFileCode ~= 63474328
    fclose(fileHandle);
    error("*.scan file type not recognized.");
end

scanFileVersion = fread(fileHandle, 1, 'double');
if scanFileVersion ~= 1
    fclose(fileHandle);
    error("*.scan file version is not supported.");
end

%% Get Header Data
Header.header = (string(fread(fileHandle, ...
    fread(fileHandle, 1, 'double'), 'double=>char').'));
Header.description = (string(fread(fileHandle, ...
    fread(fileHandle, 1, 'double'), 'double=>char').'));
Header.deviceName = (string(fread(fileHandle, ...
    fread(fileHandle, 1, 'double'), 'double=>char').'));

%% Read data from .scan file
isUniform = fread(fileHandle, 1, 'double');
Header.isUniform = isUniform;
numDims = fread(fileHandle, 1, 'double');
axisOrder = fread(fileHandle, numDims, 'double') + 1;
numSteps = fread(fileHandle, numDims, 'double');
numChannels = fread(fileHandle, 1, 'double');

Header.channelNames = strings(numChannels, 1);
for ii = 1:numChannels
    Header.channelNames(ii) = (string(fread(...
        fileHandle, fread(fileHandle, 1, 'double'), 'double=>char').'));
end

numF = fread(fileHandle, 1, 'double');
isComplex = fread(fileHandle, 1, 'double');

axisCoordinates = cell(numDims, 1);
if isUniform
    for ii = 1:numDims  % Get relative location
        axisCoordinates(ii) = {fread(fileHandle, numSteps(ii), 'double')};
    end
    fread(fileHandle, sum(numSteps), 'double'); % Discard absolute location
else
    for ii = 1:numDims  % Get relative location
        axisCoordinates(ii) = {fread(fileHandle, numSteps(1), 'double')};
    end
    fread(fileHandle, numSteps(1) .* 3, 'double'); % Discard absolute location
end

F = fread(fileHandle, numF, 'double'); % Read frequencies

numDataPoints = numF .* numChannels .* prod(numSteps);
if isComplex
    Data = fread(fileHandle, 2 .* numDataPoints, 'double');
    Data = reshape(Data, numF .* numChannels, 2, []);
    Data = complex(Data(:, 1, :), Data(:, 2, :));
else
    Data = fread(fileHandle, numDataPoints, 'double');
end

fclose(fileHandle);

%% Reorganize data into proper format
if numDims == 3
    X = axisCoordinates{1};
    Y = axisCoordinates{2};
    Z = axisCoordinates{3};
elseif numDims == 2
    X = axisCoordinates{1};
    Y = axisCoordinates{2};
    if isUniform
        Z = 0;
    else
        Z = zeros(length(X), 1);
    end
    axisOrder = [axisOrder; 3];
    numSteps = [numSteps; 1];
elseif numDims == 1
    X = axisCoordinates{1};
    if isUniform
        Z = 0;
        Y = Z;
    else
        Z = zeros(length(X), 1);
        Y = Z;
    end
    axisOrder = [axisOrder; 2; 3];
    numSteps = [numSteps; 1; 1];
else
    error(strcat("Import failed, number of dimensions in ", ...
        "*.scan file must be between 1 and 3."));
end

Data = reshape(Data, numF, numChannels, []);

if isUniform
    for ii = 1:(numDims - 1) % Flip every other row, column, etc.
        Data = reshape(Data, numF, numChannels, ...
            prod(numSteps(axisOrder(1:ii-1))), ...
            numSteps(axisOrder(ii)), []);
        Data(:, :, :, :, 2:2:end) = flip(Data(:, :, :, :, 2:2:end), 4);
    end
    
    Data = reshape(Data, [numF; numChannels; numSteps(axisOrder)].');
    Data = permute(Data, [3, 4, 5, 1, 2]);
    Data = ipermute(Data, [axisOrder; 4; 5].');
    Data = permute(Data, [1, 2, 3, 4, 5]); % (X, Y, Z, F, Channel)
else
    Data = permute(Data, [3, 1, 2]); % (Location, F, Channel)
end

end