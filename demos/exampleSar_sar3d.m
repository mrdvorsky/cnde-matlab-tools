% This example file shows how to use sar3d to create SAR images.
%
% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
f(1, 1, :) = linspace(26.5, 40, 101);

dx = 0.5;
dy = dx;

x(:, 1, 1) = -50:dx:50;
y(1, :, 1) = -40:dy:40;

%% Create SAR Data
% Example 1: Single target in center
x0_1 = [0];
y0_1 = [0];
z0_1 = [-50];
a0_1 = [1];
S_1 = createSarData3d(x, y, f, x0_1, y0_1, z0_1, a0_1);

% Example 2: Multiple targets and magnitudes, same depth
x0_2 = [0, 20, 5];
y0_2 = [-10, 15, 15];
z0_2 = [-50];
a0_2 = [1, 0.75, 0.5];
S_2 = createSarData3d(x, y, f, x0_2, y0_2, z0_2, a0_2);

% Example 3: Multiple targets, different depths
x0_3 = [0, 20, 5];
y0_3 = [-10, 15, 15];
z0_3 = [-50, -60, -80];
a0_3 = [1];
S_3 = createSarData3d(x, y, f, x0_3, y0_3, z0_3, a0_3);

% Example 4: Multiple targets, different phases
x0_4 = [0, 20, 5];
y0_4 = [-10, 15, 15];
z0_4 = [-50];
a0_4 = [1, 1j, -1];
S_4 = createSarData3d(x, y, f, x0_4, y0_4, z0_4, a0_4);

% Example 5: Multiple targets, different antenna beams
x0_5 = [0, 20, 5];
y0_5 = [-10, 15, 15];
z0_5 = [-50];
a0_5 = [1];

thetaBeamwidths = deg2rad([inf, 90, 45, 20]);
S_5 = zeros(numel(x), numel(y), numel(f), numel(thetaBeamwidths));
for ii = 1:numel(thetaBeamwidths)
    S_5(:, :, :, ii) = createSarData3d(x, y, f, x0_5, y0_5, z0_5, a0_5, ...
        ThetaBeamwidthX=thetaBeamwidths(ii), ThetaBeamwidthY=thetaBeamwidths(ii));
end

%% Perform SAR
Img_1 = sar3d(S_1, x, y, z0_1, f, ZeroPadPercent=25);
Img_2 = sar3d(S_2, x, y, z0_2, f, ZeroPadPercent=25);
Img_3 = sar3d(S_3, x, y, z0_3, f, ZeroPadPercent=25);
Img_4 = sar3d(S_4, x, y, z0_4, f, ZeroPadPercent=25);
Img_5 = sar3d(S_5, x, y, z0_5, f, ZeroPadPercent=25);

%% Plot
figure;
showImage(x, y, Img_1, DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Single Target");

figure;
showImage(x, y, Img_2, DisplayFormat="Magnitude");
colormap jet;
title("Example 2: Multiple Targets and Magnitudes, Same Depths");

figure;
for ii = 1:size(Img_3, 3)
    subplot(size(Img_3, 3), 1, ii);
    showImage(x, y, Img_3(:, :, ii), DisplayFormat="Magnitude");
    colormap jet;
    title(sprintf("Example 3: Depth = %.0f mm", z0_3(ii)));
end

figure;
h = subplot(2, 1, 1);
showImage(x, y, Img_4, DisplayFormat="Magnitude");
colormap jet;
title("Example 4: Multiple Targets, Different Phases");
subplot(2, 1, 2);
showImage(x, y, Img_4, DisplayFormat="MagPhase");

figure;
for ii = 1:size(Img_5, 4)
    subplot(2, 2, ii);
    showImage(x, y, Img_5(:, :, 1, ii), DisplayFormat="Magnitude");
    colormap jet;
    title(sprintf("Example 5: Beamwidth = %.0f deg", ...
        rad2deg(thetaBeamwidths(ii))));
end


