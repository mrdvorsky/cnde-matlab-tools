% This example file shows how to use sar2d to create 2D SAR images.
%
% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
f(1, :) = linspace(26.5, 40, 101);

dx = 0.5;
dz = 0.5;

x(:, 1) = -50:dx:50;
z(1, :) = -(0:dz:100);

%% Create SAR Data
% Example 1: Single target
x0_1 = [0];
z0_1 = [-50];
a0_1 = [1];
S_1 = createSarData2d(x, f, x0_1, z0_1, a0_1);

% Example 2: Multiple targets and magnitudes, same depth
x0_2 = [-20, 0, 20];
z0_2 = [-50];
a0_2 = [1, 0.75, 0.5];
S_2 = createSarData2d(x, f, x0_2, z0_2, a0_2);

% Example 3: Multiple targets, different depths
x0_3 = [-20, 0, 20];
z0_3 = [-30, -50, -70];
a0_3 = [1];
S_3 = createSarData2d(x, f, x0_3, z0_3, a0_3);

% Example 3: Multiple targets, different depths, no range compensation
S_4 = createSarData2d(x, f, x0_3, z0_3, a0_3, ...
    UseRangeForAmplitude=false);

% Example 5: Multiple targets, different antenna beams
x0_5 = [-20, 0, 20];
z0_5 = [-30, -50, -70];
a0_5 = [1, 2, 3];

thetaBeamwidths = deg2rad([inf, 90, 45, 20]);
S_5 = zeros(numel(x), numel(f), numel(thetaBeamwidths));
for ii = 1:numel(thetaBeamwidths)
    S_5(:, :, ii) = createSarData2d(x, f, x0_5, z0_5, a0_5, ...
        ThetaBeamwidthX=thetaBeamwidths(ii));
end

%% Perform SAR
Img_1 = sar2d(S_1, x, z, f, ZeroPadPercent=25);
Img_2 = sar2d(S_2, x, z, f, ZeroPadPercent=25);
Img_3 = sar2d(S_3, x, z, f, ZeroPadPercent=25);
Img_4 = sar2d(S_4, x, z, f, ZeroPadPercent=25);
Img_5 = sar2d(S_5, x, z, f, ZeroPadPercent=25);

%% Plot
figure;
showImage(x, z, Img_1, DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Single Target");
xlabel("x, mm");
ylabel("z, mm");

figure;
showImage(x, z, Img_2, DisplayFormat="Magnitude");
colormap jet;
title("Example 2: Multiple Targets and Magnitudes, Same Depths");
xlabel("x, mm");
ylabel("z, mm");

figure;
showImage(x, z, Img_3, DisplayFormat="Magnitude");
colormap jet;
title("Example 3: Multiple Targets, Different Depths");
xlabel("x, mm");
ylabel("z, mm");

figure;
showImage(x, z, Img_4, DisplayFormat="Magnitude");
colormap jet;
title("Example 4: Different Depths, No Range Compensation");
xlabel("x, mm");
ylabel("z, mm");

figure;
for ii = 1:size(Img_5, 3)
    subplot(2, 2, ii);
    showImage(x, z, Img_5(:, :, ii), DisplayFormat="Magnitude");
    colormap jet;
    title(sprintf("Example 5: Beamwidth = %.0f deg", ...
        rad2deg(thetaBeamwidths(ii))));
    xlabel("x, mm");
    ylabel("z, mm");
end


