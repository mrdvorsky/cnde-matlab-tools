function [ ] = CalibrateRadialScan(filePath, calAppend, options)
%CALIBRATEFROMSHORT Creates a calibrated .mat file from a .scan and a
%   .s2p file

arguments
    filePath {mustBeTextScalar};
    calAppend {mustBeTextScalar} = "";
    options.UsePhaseOnly(1, 1) {mustBeNumericOrLogical} = true;
    options.ZeroPadPercent(1, 1) {mustBeNonnegative} = 50;
end

%% Get File Names
[fileDirectory, fileName, ~] = fileparts(filePath);

fileNameOut = fullfile(fileDirectory, fileName);

%% Read Files
[x, y, f, Data, Header] = importScan(filePath);

try
    cal = readSnp(strcat(fullfile(fileDirectory, ...
        strcat(fileName, calAppend)), ".s2p"));
    calData(1, 1, :) = cal.Parameters(1, 1, :);
catch
    error("File '%s.s2p' does not exist or has the wrong format.", ...
        fullfile(fileDirectory, fileName));
end

%% Calibrate Scan Data
if options.UsePhaseOnly
    Data = Data ./ exp(1j .* angle(calData));
else
    Data = Data ./ calData;
end

%% 3D Polarimetric Calibration Coefficients
alpha = 0.8010;
beta = 2.8551;

%% Spectrum Wavenumbers
zx = round(options.ZeroPadPercent ./ 100 .* length(x));
zy = round(options.ZeroPadPercent ./ 100 .* length(y));

c = 299.792458;
k(1, 1, :) = (2*pi) .*f ./ c;

dx = x(2) - x(1);
dy = y(2) - y(1);
[iy, ix] = freqspace([zx + size(Data, 1); zy + size(Data, 2)]);
kx(:, 1, 1) = ifftshift(ix * pi / dx);
ky(1, :, 1) = ifftshift(iy * pi / dy);

%% Calculate Filters
phiP = angle(kx + 1j*ky);
thetaP = asin(0.5 * hypot(kx, ky) ./ k);

Fid = 1 + 0*(kx + ky + k);

Fxx = (alpha .* cos(thetaP).^2 - sin(thetaP).^2) ./ (alpha.*beta - 1) ...
    + 2 * cos(2 * phiP) .* sin(thetaP).^2;
Fyy = (alpha .* cos(thetaP).^2 - sin(thetaP).^2) ./ (alpha.*beta - 1) ...
    - 2 * cos(2 * phiP) .* sin(thetaP).^2;
Fzz = (beta .* sin(thetaP).^2 - cos(thetaP).^2) ./ (alpha.*beta - 1);

Fxy = 2 * sin(2*phiP) .* sin(thetaP).^2;
Fxz = cos(phiP) .* sin(thetaP) .* cos(thetaP);
Fyz = sin(phiP) .* sin(thetaP) .* cos(thetaP);

%% Calculate Filtered Images
DataSpectrum = fft2(Data, length(kx), length(ky));
DataSpectrumAll = DataSpectrum .* cat(4, Fid, Fxx, Fyy, Fzz, Fxy, Fxz, Fyz);
DataAll = ifft2(DataSpectrumAll);

%% Save Data
outData.Data = DataAll(1:length(x), 1:length(y), :, :);
outData.X = x;
outData.Y = y;
outData.F = f;
outData.Header = Header;
outData.Header.channelNames = ...
    ["S11", "Sxx", "Syy", "Szz", "Sxy", "Sxz", "Syz"];

save(fileNameOut, "-struct", "outData");

end
