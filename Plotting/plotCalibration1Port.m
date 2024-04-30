function [] = plotCalibration1Port(T, options)
%PLOTCALIBRATION1PORT Plot calibration function on current plot.
%
% Author: Matt Dvorsky

arguments
    T(1, 1, 4);
    options.NumLinesR(1, 1) {mustBeInteger, mustBePositive} = 10;
    options.NumLinesPhi(1, 1) {mustBeInteger, mustBePositive} = 32;
end

%% Create Lines
nR = options.NumLinesR;
nPhi = options.NumLinesPhi;
phiOrig(1, 1, 1, 1, :, :) = exp(1j * linspace(0, 2*pi, 1000).') ...
    .* ((1:nR)./nR);
rOrig(1, 1, 1, 1, :, :) = linspace(0, 1, 1000).' ...
    .* exp(1j * (1:nPhi) ./ nPhi * 2*pi);

phiPlot = squeeze(applyInverseCalibration(T, phiOrig));
rPlot = squeeze(applyInverseCalibration(T, rOrig));

plots(phiPlot, "b", LineWidth=0.5, DisplayName="");
hold on;
plots(rPlot, "r", LineWidth=0.5, DisplayName="");


end

