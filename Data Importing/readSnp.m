function [S, f, commentLines, Z0] = readSnp(filenameIn)
%READSNP Read the *.snp file and adjust units to GHz.
% Imports an *.snp file specified by filenameIn. If filenameIn does not
% specify an extension, this function will search for files with the name
% "{filenameIn}.s*p". The units of the output will be in GHz regardless of
% the units used in the file.
%
% Example Usage:
%   [S, f] = readSnp("file");   % Finds any file with the name "file.s*p".
%   [S, f] = readSnp("file.s2p");
%   [S, f, commentLines] = readSnp("file.s1p");
%
% Inputs:
%   filenameIn - Filename to search for. If no extension is given, will
%       search for any ".s*p" file.
% Outputs:
%   S - S-parameter array with size nPorts-by-nPorts-by-nFrequencies-by-...
%   f - Frequency vector, in GHz.
%   commentLines - String vector containing all lines starting with "!".
%   Z0 - System impedance.
%
% Author: Matt Dvorsky

arguments
    filenameIn {mustBeTextScalar};
end

%% Open File
% Search for ".s*p" file if no extension was provided.
[path, name, ext] = fileparts(filenameIn);
if (ext == "")
    filenameSearch = fullfile(path, strcat(name, ".s*p"));
    fileMatches = dir(filenameSearch);
    if isempty(fileMatches)
        error("No file matching '%s' found.", filenameSearch);
    end
    if numel(fileMatches) > 1
        warning("Multiple files with pattern '%s' found: {%s}. " + ...
            "Using the first file only.", filenameSearch, ...
            strjoin({fileMatches.name}, ", "));
    end
    filename = fullfile(fileMatches(1).folder, fileMatches(1).name);
else
    filename = filenameIn;
end

%% Read Data
FileData = readmatrix(filename, FileType="text", ...
    OutputType="double", CommentStyle="!");
FileLines = readlines(filename);

%% Parse Option Line and Comment Lines
optionLine = split(FileLines(find(startsWith(FileLines, "#"), 1)));
if numel(optionLine) < 6
    error("Option line not found or has wrong format in '%s'. " + ...
        "File format may be incorrect.", filename);
end

if nargout >= 3
    commentLines = FileLines(startsWith(FileLines, "!"));
end

if nargout >= 4
    Z0 = str2double(optionLine(6));
end

%% Format Data
numPorts = round(sqrt(0.5*(size(FileData, 2) - 1)));
if (numPorts*numPorts) ~= 0.5*(size(FileData, 2) - 1)
    error("Wrong number of columns in '%s'. File format may be incorrect.", ...
        filename);
end

% Check for duplicated frequency vector.
fAll = FileData(:, 1);
[fcounts] = groupcounts(fAll);
f = reshape(fAll(1:numel(fcounts)), 1, 1, []);
if any(fcounts(1) ~= fcounts) || numel(unique(f)) ~= numel(f)
    error("Frequency column is invalid in '%s'.", filename);
end

S = reshape(complex(FileData(:, 2:2:end), FileData(:, 3:2:end)), ...
    numPorts, numPorts, numel(f), []);

%% Check for Units and Data Format
switch optionLine(2)
    case "HZ"
        f = 1e-9 * f;
    case "KHZ"
        f = 1e-6 * f;
    case "MHZ"
        f = 1e-3 * f;
    case "GHZ"
    otherwise
        error("Unit spec '%s' invalid in '%s'.", optionLine(2), filename);
end

switch optionLine(4)
    case "RI"
    case "MA"
        S = real(S) .* exp(1j .* deg2rad(imag(S)));
    case "DB"
        S = 10.^(0.05 * real(S)) .* exp(1j .* deg2rad(imag(S)));
    otherwise
        error("Format spec '%s' invalid in '%s'.", optionLine(4), filename);
end

end

