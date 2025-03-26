% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
nPorts = 2;
nCalMeas = 3;
nMeas = nCalMeas + 10;
nFreqs = 1;

%% Generate Calibration Adapter
T = generateCalibrationModel(nPorts, nFreqs, IsLeaky=true, IsReciprocal=true);

%% Create Calibration Standards
S = cat(4, diag([1j^0.5, 1j]).^0, diag([1j^0.5, 1j]).^1, ...
    diag([1j^0.5, 1j]).^2);

%% Find Measurements
Sm = applyInverseCalibration(T, S);

%% Calibrate
reim = @(x) [x(1) + 1j*x(2), x(3) + 1j*x(4), x(5) + 1j*x(6)];
cat4 = @(x) cat(4, x(1), x(2), x(3));
cal = @(x) solveCalibrationModel(S, eye(2).*cat4(reim(x)));
opt = @(x) svds(cal(x), 1, "smallest");
% optTest = @(x) opt([1, 0, 0.5, 0.5, x(1), x(2)]);

% options = optimoptions("lsqnonlin", Display="iter-detailed");
% x = lsqnonlin(opt, [1, 0, 0, 1, -1, 0], -ones(6, 1), ones(6, 1), options)

% options = optimoptions("patternsearch", Display="iter");
% x = patternsearch(opt, [1, 0, 0, 1, -1, 0], [], [], [], [], -ones(6, 1), ones(6, 1), [], options)

%% Manual
y1(:, 1) = exp(1j * linspace(-pi, pi, 101));
y1 = y1(1:end-1, 1);
y2(1, :) = y1;

x1 = 0;
x2 = 1;
x3 = real(y1);
x4 = imag(y1);
x5 = real(y2);
x6 = imag(y2);

Data = flattenArrays(x1, x2, x3, x4, x5, x6);
out = zeros(sizeCompatible(y1, y2));
for ii = 1:size(Data, 1)
    if mod(ii, 1000) == 0
        disp(ii)
    end
    out(ii) = opt([Data(ii, :)]);
end

%% Test
figure;
showImage(angle(y1), angle(y1), out);
colormap jet;






