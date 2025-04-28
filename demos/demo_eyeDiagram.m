clc;
clear;
close all;

%% Inputs
numSamplesPerBit = 100;
numBits = 1000;

bitRate = 2;

f0 = [0, 1, 2, 3, 4, 5];
mag = [1, 1, 1, 1, 1, 0];
phase = [0, 0, 0, 0, 0, 0];

magfun = @(f) interp1(f0, mag, f, "pchip", 0);
phasefun = @(f) interp1(f0, phase, f, "pchip", 0);
S = @(f) magfun(abs(f)) .* exp(-1j * deg2rad(phasefun(abs(f))));

%% Create Bit Stream
bits = rand(numBits, 1) > 0.5;
bitStream = repelem(bits, numSamplesPerBit);

t(:, 1) = (0:numBits*numSamplesPerBit - 1) ./ (bitRate * numSamplesPerBit);

%% Modified Bitstream
w = fftCoordinates(t);
outStream = real(ifft(S(w ./ (2*pi)) .* fft(bitStream)));

%% Plot
f = linspace(0, 5, 10000);

% figure;
% plot(f, phasefun(f), "", LineWidth=1.5);
% grid on;
% ylabel("Magnitude");
% xlabel("f (GHz)");

figure;
streamPlot = plot(t(1:numSamplesPerBit), ...
    reshape(outStream, [numSamplesPerBit, numBits]), ...
    "b", LineWidth=1.5);
grid on;
ylim([-0.1, 1.1]);

%% Interactive Plot
figure;
magPlot = plot(f, magfun(f), "", LineWidth=1.5);
grid on;
ylabel("Magnitude");
xlabel("f (GHz)");
ylim([-0.1, 1.1]);

hold on;
interactiveDots(f0, mag, ...
    {@updateFun, magPlot, streamPlot, bitStream, w, numBits});


%% Helper
function [x, y] = updateFun(x, y, ind, magPlot, streamPlot, bitStream, w, numBits)
    magfun = @(f) interp1(x, y, f, "pchip", 0);
    phasefun = @(f) interp1([0, 5], [0, 0], f, "pchip", 0);
    S = @(f) magfun(abs(f)) .* exp(-1j * deg2rad(phasefun(abs(f))));

    outStream = reshape(...
        real(ifft(S(w ./ (2*pi)) .* fft(bitStream))), ...
        [], numBits);

    magPlot.YData = magfun(magPlot.XData);
    for ii = 1:numBits
        streamPlot(ii).YData = outStream(:, ii);
    end
end







