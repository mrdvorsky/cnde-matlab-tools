function [varargout] = importSdt(filenameIn, options)
%IMPORTSDT Imports an SDT file from InspectionWare.
% This function imports am SDT file from InspectionWare given the SDT
% filename with or without the ".sdt" extension. Returns a cell array of
% data sets, the x- and y- and ... dimensions in mm, and a cell array of
% time steps for each data set in ns.
%
% This function supports any number of scan dimensions, and will read this
% information from the header of the SDT file. The number of output
% arguments will determine the dimensionality of the output data, which
% must be greater than the number of dimensions in the SDT file.
%
% Example Usage:
%   [Data, x, y, t, Header] = importSdt("testFile");
%   [Data, x, y, z, t, Header] = importSdt("testFile.sdt");
%   DataLast = Data{end};       % Get last data set.
%   tLast = t{end};             % Get last time vector.
%
% Inputs:
%   filename - Scalar string containing the filepath. Can have the ".sdt"
%       extension.
%
% Outputs:
%   Data - Cell array of data sets. Each data set is a 3D array of
%       amplitude values where the dimensions correspond to x, y, and t.
%   axisCoordinates (Repeating) - Vector of coordinates for the n-th axis,
%       in units of mm.
%   t - Cell array of time coordinate vectors, in ns.
%   Header - Struct with various parsed information from the file header.
%
% Named Arguments:
%   MaxHeaderSize (100000) - Maximum size of SDT header, in bytes. If the
%       header is longer than this, an error will be thrown.
%
% Author: Matt Dvorsky

arguments
    filenameIn {mustBeTextScalar};
    options.MaxHeaderSize(1, 1) {mustBePositive, mustBeInteger} = 100000;
end

%% Check Filepath Input
[path, name, ext] = fileparts(filenameIn);
if (ext == "")
    filename = fullfile(path, strcat(name, ".sdt"));
else
    filename = filenameIn;
end

%% Read File Data
[fileID, fopenError] = fopen(filename, "r");
if fileID == -1
    error("Can't open file '%s' because: %s.", filename, fopenError);
end

RawData = fread(fileID, "uint8=>uint8");
fclose(fileID);

HeaderData = char(RawData(1:min(numel(RawData), options.MaxHeaderSize))).';
HeaderSplit = split(HeaderData, sprintf("|^Data Set^|\r\n"));

if numel(HeaderSplit) < 2
    error("Error reading '%s'. Could not find the string " + ...
        "'|^Data Set^|\\r\\n' in the first (%d) bytes of the SDT file. " + ...
        "File may be corrupted or the header may be larger than " + ...
        "the 'MaxHeaderSize' argument.", ...
        filename, options.MaxHeaderSize);
end

HeaderString = string(HeaderSplit{1});
RawData(1:strlength(HeaderString) + 14) = [];

%% Parse Header
[axisCoordinates, t, Header] = parseSdtHeader(HeaderString);

%% Set Output Sizes
numOutputDimensions = nargout - 3;

if numOutputDimensions < Header.numAxes
    error("Error reading '%s'. Requested number of output dimensions " + ...
        "(%d) is less than the number of dimensions in the SDT file (%d).", ...
        filename, numOutputDimensions, Header.numAxes);
elseif numOutputDimensions > Header.numAxes
    warning("Error reading '%s'. Requested number of output dimensions " + ...
        "(%d) is greater than the number of dimensions in the scan " + ...
        "file (%d). Extra singleton dimensions will be added to the output.", ...
        filename, numOutputDimensions, Header.numAxes);
end

for ii = 1:numel(axisCoordinates)
    axisCoordinates{ii} = shiftdim(axisCoordinates{ii}(:), 1 - ii);
end
axisCoordinates = [axisCoordinates; ...
    num2cell(zeros(numOutputDimensions - numel(axisCoordinates), 1))];
% axisCoordinates = resize(axisCoordinates, ...
%     numOutputDimensions, FillValue={0});

axisSizes = cellfun(@numel, axisCoordinates);

%% Read Data
if Header.RawDataSizeBytes > numel(RawData)
    error("Size of data in file (%d) is less than the " + ...
        "expected data size based on the header (%d).", ...
        numel(RawData), Header.RawDataSizeBytes);
end

DataSets = cell(Header.numDataSets, 1);
for ii = 1:Header.numDataSets
    t{ii} = shiftdim(t{ii}(:), -numOutputDimensions);
    
    numDataElementsCurrent = prod(axisSizes) * numel(t{ii}) ...
        * double(Header.DataSetDict{ii}("Element Size (bytes)"));
    RawDataCurrent = RawData(1:numDataElementsCurrent);

    dataRepr = Header.DataSetDict{ii}("Element Representation");
    switch dataRepr
        case "INTEGER 16"
            DataCurrent = inv(2^16) ...
                .* double(typecast(RawDataCurrent, "int16"));
            DataCurrent = Header.DataSetRangeMin(ii) + (DataCurrent + 0.5) ...
                .* (Header.DataSetRangeMax(ii) - Header.DataSetRangeMin(ii));
        case "FLOAT 32"
            DataCurrent = inv(1) ...
                .* double(typecast(RawDataCurrent, "single"));
        otherwise
            error("DataSet representation '%s' not supported.", ...
                dataRepr);
    end

    DataSets{ii} = permute(...
        reshape(DataCurrent, [numel(t{ii}); axisSizes].'), ...
        circshift(1:numel(axisSizes) + 1, -1));

    RawData = RawData(numDataElementsCurrent + 1:end);
end

%% Set Outputs
varargout = [{DataSets}; axisCoordinates(:); {t}; {Header}];

end








%% Header Parsing Helper Function
function [axisCoordinates, t, Header] = parseSdtHeader(headerString)

% Convert header into dictionarys for easy lookup.
HeaderLines = splitlines(headerString);
HeaderLines = HeaderLines(strlength(HeaderLines) ~= 0);

dataStartLines = startsWith(HeaderLines, whitespacePattern(0, inf) + "-");
HeaderSplit = mat2cell(HeaderLines, groupcounts(cumsum(dataStartLines)));

HeaderDict = cell(numel(HeaderSplit), 1);
for gg = 1:numel(HeaderDict)
    HeaderDict{gg} = dictionary();
    for ii = 2:numel(HeaderSplit{gg})
        keyValue = split(HeaderSplit{gg}(ii), ":");
        HeaderDict{gg}(strtrim(keyValue{1})) = strtrim(keyValue{2});
    end
end

Header.FileDict = HeaderDict{1};
Header.numAxes = double(Header.FileDict("Number of Scan Axes"));
Header.numDataSets = double(Header.FileDict("Number of Data Subsets"));

Header.AxisDict = HeaderDict(2:1 + Header.numAxes);
Header.DataSetDict = HeaderDict(1 + Header.numAxes + (1:Header.numDataSets));

% Add file information to Header struct.
Header.headerString = headerString;
Header.headerLines = HeaderLines;

% Parse axis coordinate data.
Header.AxisUnits = strings(Header.numAxes, 1);
axisCoordinates = cell(Header.numAxes, 1);
for ii = 1:numel(axisCoordinates)
    axisSize = double(Header.AxisDict{ii}("Number of Sample Points"));

    if axisSize ~= 1
        [axisStart, ~] = convertUnitToMM(Header.AxisDict{ii}("Minimum Sample Position"));
        [axisSpacing, axisUnit] = convertUnitToMM(Header.AxisDict{ii}("Sample Resolution"));
    else
        axisStart = 0;
        axisSpacing = 1;
        axisUnit = "mm";
    end

    axisCoordinates{ii} = axisSpacing.*(0:axisSize - 1) + axisStart;
    
    Header.AxisUnits(ii) = axisUnit;
end

% Parse DataSet information.
Header.DataSetLabels = strings(Header.numDataSets, 1);
Header.DataSetRangeMin = zeros(Header.numDataSets, 1);
Header.DataSetRangeMax = zeros(Header.numDataSets, 1);
Header.DataSetRangeUnits = strings(Header.numDataSets, 1);
Header.DataSetTimeUnits = strings(Header.numDataSets, 1);
Header.RawDataSizeBytes = 0;
t = cell(Header.numDataSets, 1);
for ii = 1:numel(t)
    Header.DataSetLabels(ii) = Header.DataSetDict{ii}("Subset Label");

    tSize = double(Header.DataSetDict{ii}("Number of Sample Points"));
    
    if tSize ~= 1
        [tStart, tUnit] = convertUnitToNS(Header.DataSetDict{ii}("Minimum Sample Position"));
        tSpacing = convertUnitToNS(Header.DataSetDict{ii}("Sample Resolution"));
    else
        tStart = 0;
        tSpacing = 1;
        tUnit = "ns";
    end

    t{ii} = tSpacing.*(0:tSize - 1) + tStart;

    Header.RawDataSizeBytes = Header.RawDataSizeBytes ...
        + tSize * double(Header.DataSetDict{ii}("Element Size (bytes)"));

    [dataSetRange, dataSetUnit] = ...
        convertRangeToUnit(Header.DataSetDict{ii}("Measurement Range"));
    Header.DataSetRangeMin(ii) = dataSetRange(1);
    Header.DataSetRangeMax(ii) = dataSetRange(1) + dataSetRange(2);
    Header.DataSetRangeUnits(ii) = dataSetUnit;
    Header.DataSetTimeUnits(ii) = tUnit;
end

Header.RawDataSizeBytes = Header.RawDataSizeBytes ...
    .* prod(cellfun(@numel, axisCoordinates));

end

%% Unit Conversion Helper Functions
function [val_mm, unit] = convertUnitToMM(val_text)
    valUnit = split(val_text);
    val = double(valUnit(1:end - 1));
    unit = valUnit(end);

    switch unit
        case "in"
            val_mm = val * 25.4;
            unit = "mm";
        otherwise
            val_mm  = val;
            warning("Unit specifier '%s' not supported.", unit);
    end
end

function [val_ns, unit] = convertUnitToNS(val_text)
    valUnit = split(val_text);
    val = double(valUnit(1:end - 1));
    unit = valUnit(end);

    switch unit
        case "us"
            val_ns = val * 1000;
            unit = "ns";
        otherwise
            val_ns = val;
            warning("Unit specifier '%s' not supported.", unit);
    end
end

function [val, unit] = convertRangeToUnit(val_text)
    valUnit = split(val_text);
    val = double(valUnit(1:end - 1));
    unit = valUnit(end);

    switch unit
        case "V"
            val = 1 * val;
        case "us"
            val = 1000 * val;
            unit = "ns";
        otherwise
            warning("Unit specifier '%s' not supported.", unit);
    end
end
