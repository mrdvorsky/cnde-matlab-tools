function [X, Y, Z, F, Data, Header] = importScan(Filepath)

X = [];
Y = [];
Z = [];
F = [];
Data = [];

File = fopen(Filepath);

if File == -1
    error("File not found.");
end

%% Get Version Info
scanFileCode = fread(File, 1, 'double');
if scanFileCode ~= 63474328
    fclose(File);
    error("*.scan file type not recognized.");
end

scanFileVersion = fread(File, 1, 'double');
if scanFileVersion ~= 1
    fclose(File);
    error("*.scan file version is not supported.");
end

%% Get Header Data
Header.header = (string(fread(File, ...
    fread(File, 1, 'double'), 'double=>char').'));
Header.description = (string(fread(File, ...
    fread(File, 1, 'double'), 'double=>char').'));
Header.deviceName = (string(fread(File, ...
    fread(File, 1, 'double'), 'double=>char').'));

%% Read data from .scan file
isUniform = fread(File, 1, 'double');
Header.isUniform = isUniform;
numDims = fread(File, 1, 'double');
axisOrder = fread(File, numDims, 'double') + 1;
numSteps = fread(File, numDims, 'double');
numChannels = fread(File, 1, 'double');

Header.channelNames = strings(numChannels, 1);
for ii = 1:numChannels
    Header.channelNames(ii) = (string(fread(...
        File, fread(File, 1, 'double'), 'double=>char').'));
end

numF = fread(File, 1, 'double');
isComplex = fread(File, 1, 'double');

axisCoordinates = cell(numDims, 1);
if isUniform
    for ii = 1:numDims  % Get relative location
        axisCoordinates(ii) = {fread(File, numSteps(ii), 'double')};
    end
    fread(File, sum(numSteps), 'double'); % Discard absolute location
else
    for ii = 1:numDims  % Get relative location
        axisCoordinates(ii) = {fread(File, numSteps(1), 'double')};
    end
    fread(File, numSteps(1) .* 3, 'double'); % Discard absolute location
end

F = fread(File, numF, 'double'); % Read frequencies

numDataPoints = numF .* numChannels .* prod(numSteps);
if isComplex
    Data = fread(File, 2 .* numDataPoints, 'double');
    Data = reshape(Data, numF .* numChannels, 2, []);
    Data = complex(Data(:, 1, :), Data(:, 2, :));
else
    Data = fread(File, numDataPoints, 'double');
end

fclose(File);

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