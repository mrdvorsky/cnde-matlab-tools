function [varargout] = importScan(filenameIn, options)
%IMPORTSCAN Import a ".scan" file created by the amntl scanner program.
% This function imports and parses a ".scan" file.
%
% Example Usage:
%   [x, y, f, Data, Header] = importScan(filename);
%   [x, y, z, f, Data, Header] = importScan(filename);
%
% Inputs:
%   filenameIn - Path to the file. If the file has no extension, ".scan"
%       will be automatically appended.
%   NumOutputDimensions (optional) - The number of output dimensions to
%       use. This should be equal to the number of dimensions specified in
%       the output parameters.
% Output:
%   x, y, z, ... - Vectors containing the coordinates of each scan point.
%       If the scan is uniform, each vector will contain a unique, sorted,
%       and uniformly increasing list of coordinates for the corresponding
%       dimension. Otherwise, each vector will contain one element for each
%       scan point. The number of coordinate vectors is variable and should
%       be at equal to or higher than the index of the highest nonzero
%       dimension used in the scan.
%   Data - If the data is uniform, Data(i1, i2, ..., ff, cc) will be equal
%       to the measurement made at coordinate (x(i0), y(i1), ...) when
%       using a frequency of f(ff) and using channel cc. The size of Data
%       depends on the number of output parameters specified. For example,
%       calling as [x, y, f, Data, Header] = importScan(...) will result in
%       Data being (numX by numY by numF by numChannels).
%       If the data is nonuniform, Data will be (numPoints by numF by
%       numChannels), and Data(ii, ff, cc) will be the measurement made at
%       coordinate (x(ii), y(ii), ...).
%
% Author: Matt Dvorsky

arguments
    filenameIn {mustBeText};
    options.NumOutputDimensions(1, 1) = -1;
end

%% Check Inputs
if options.NumOutputDimensions < 0
    options.NumOutputDimensions = nargout - 3;
end

if options.NumOutputDimensions ~= nargout - 3
    outputParameterString = strcat(join(compose("axis%d, ", ...
        1:options.NumOutputDimensions), ""), "Data, Header");
    warning(strcat("Number of output dimensions is not consistent with ", ...
        "the number of output parameters. The format of the function call ", ...
        "should be [%s] = importScan(filename, NumOutputDimensions=%d);"), ...
        outputParameterString, options.NumOutputDimensions);
end

%% Open File
% Add ".scan" extension if filenameIn has no extension.
[path, name, ext] = fileparts(filenameIn);
if (ext == "")
    filename = fullfile(path, strcat(name, ".scan"));
else
    filename = filenameIn;
end

% Don't forget to close the fileHandle whenever returning or throwing.
fileHandle = fopen(filename);
if fileHandle == -1
    error("Scan file '%s' not found.", filename);
end

%% Get Version Info
% Scan file code is an value contained in the first 8 bytes of the file.
scanFileCode = fread(fileHandle, 1, "double");
if scanFileCode ~= 63474328
    fclose(fileHandle);
    error("*.scan file type not recognized.");
end

% Currently, there is only 1 version of the scan file format.
scanFileVersion = fread(fileHandle, 1, "double");
if scanFileVersion ~= 1
    fclose(fileHandle);
    error("*.scan file version is not supported.");
end

%% Read Remaining Header Data From ".scan" File
Header.header = string(fread(fileHandle, ...
    fread(fileHandle, 1, "double"), "double=>char").');
Header.description = string(fread(fileHandle, ...
    fread(fileHandle, 1, "double"), "double=>char").');
Header.deviceName = string(fread(fileHandle, ...
    fread(fileHandle, 1, "double"), "double=>char").');

isUniform = fread(fileHandle, 1, "double");
Header.isUniform = isUniform;
numDims = fread(fileHandle, 1, "double");
axisOrder = 1 + fread(fileHandle, numDims, "double");
dimSize = fread(fileHandle, numDims, "double");
numChannels = fread(fileHandle, 1, "double");

Header.channelNames = strings(numChannels, 1);
for ii = 1:numChannels
    Header.channelNames(ii) = (string(fread(...
        fileHandle, fread(fileHandle, 1, "double"), "double=>char").'));
end

numF = fread(fileHandle, 1, "double");
isComplex = fread(fileHandle, 1, "double");

axisCoordinates = cell(numDims, 1);
if isUniform
    % In the uniform case, numSteps(n) will contain the size of the nth
    % dimension. The file will contain numSteps(n) data points for each
    % dimension, specifying the relative coordinates of each uniform grid.
    % Then, the absolute coordinates are specified in the same way. The
    % absolute coordinates are currently ignored.
    for ii = 1:numDims  % Get relative location vector
        axisCoordinates(ii) = {fread(fileHandle, dimSize(ii), "double")};
    end
    fread(fileHandle, sum(dimSize), "double"); % Discard absolute location
else
    % In the nonuniform case, numSteps(1) will contain the total number of
    % scan points. The file will contain numSteps(1) data points for each
    % dimension, specifying the relative coordinates of each every scan
    % point grid. Then, the absolute coordinates are specified in the same
    % way. The absolute coordinates are currently ignored.
    for ii = 1:numDims  % Get relative location
        axisCoordinates(ii) = {fread(fileHandle, dimSize(1), "double")};
    end
    fread(fileHandle, dimSize(1) .* 3, "double"); % Discard absolute location
end

% Next, the file contains the vector of frequencies in GHz
f = fread(fileHandle, numF, "double"); % Read frequency vector

% If end of file was reached, header is missing data.
if feof(fileHandle)
    fclose(fileHandle);
    error("Scan file '%s' header is corrupted.", filename);
end

%% Read Scan Measurement Data
numDataPoints = numF .* numChannels .* prod(dimSize);

% Read data from file.
numDataPointsToRead = numDataPoints * (1 + isComplex);
Data = fread(fileHandle, numDataPointsToRead, "double");

% Check for missing data
if length(Data) < numDataPointsToRead
    warning(strcat("Scan file '%s' contains (%d) measurement points, ", ...
        "which is less than the (%d) measurement points expected. ", ...
        "Data will be padded with zeros."), ...
        filename, length(Data), numDataPointsToRead);
    
    % Pad Missing Data With Zeros
    Data = [Data; zeros(numDataPointsToRead - length(Data), 1)];
end

% Check for too much data
fread(fileHandle, 1);
if ~feof(fileHandle)
    warning(strcat("Scan file '%s' contains more data than expected. ", ...
        "The extra data will be ignored."), filename);
end

% Reorganize complex data.
if isComplex
    % Complex data is partially interleaved real imaginary. Every scan
    % point contains all real data followed by all imaginary data.
    Data = reshape(Data, numF .* numChannels, 2, []);
    Data = complex(Data(:, 1, :), Data(:, 2, :));
end

% Done with reading data from file.
fclose(fileHandle);

%% Check File Dimensions and Requested Output Dimensions
if options.NumOutputDimensions < numDims
    if all(dimSize(options.NumOutputDimensions + 1:end) == 1)
        % In this case
    else
        error(strcat("Requested number of output dimensions (%d) is ", ...
            "less than the number of dimensions in the scan file (%d)."), ...
            options.NumOutputDimensions, numDims);
    end
end

if options.NumOutputDimensions > numDims
    warning(strcat("Requested number of output dimensions (%d) is greater ", ...
        "than the number of dimensions in the scan file (%d). ", ...
        "Extra dimensions with a size of 1 will be added to the output."), ...
        options.NumOutputDimensions, numDims);
end

%% Set Output Coordinates and Frequencies
varargout = cell(options.NumOutputDimensions + 3, 1);

% Set output coordinate vectors to values parsed from scan file.
for ii = 1:numDims
    varargout{ii} = axisCoordinates{ii};
end

% Set remaining requested output coordinate vectors to 0.
for ii = (numDims + 1):options.NumOutputDimensions
    if isUniform
        varargout{ii} = 0;
    else
        varargout{ii} = zeros(prod(dimSize), 1);
    end
end

%% Reorganize Data
% Set output axis order based on number of requested channels.
% Add additional indices to axis order if needed, and add 1's to the output
% dimensions sizes.
outputAxisOrder = [axisOrder; ((numDims + 1):options.NumOutputDimensions).'];
outputDimSize = [dimSize; 1 + 0*((numDims + 1):options.NumOutputDimensions).'];

Data = reshape(Data, numF, numChannels, []);
if isUniform
    % Flip every other row, column, etc., to account for raster scan.
    for ii = 1:(numDims - 1)
        Data = reshape(Data, numF, numChannels, ...
            prod(outputDimSize(outputAxisOrder(1:ii-1))), ...
            outputDimSize(outputAxisOrder(ii)), []);
        Data(:, :, :, :, 2:2:end) = flip(Data(:, :, :, :, 2:2:end), 4);
    end
    
    Data = reshape(Data, [numF; numChannels; ...
        outputDimSize(outputAxisOrder)].');
    
    % Permute so dimensions are (a1, a2, ... , f, Channel)
    Data = ipermute(Data, [length(outputAxisOrder) + [1; 2]; ...
        outputAxisOrder].');
else
    % Permute so dimensions are (Scan Location, f, Channel)
    Data = permute(Data, [3, 1, 2]);
end

%% Set Remaining Outputs
varargout{options.NumOutputDimensions + 1} = f;
varargout{options.NumOutputDimensions + 2} = Data;
varargout{options.NumOutputDimensions + 3} = Header;

end