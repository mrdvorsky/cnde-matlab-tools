% This example file shows how to use sar3d to create SAR images of a
% multilayer structure.
%
% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
f(1, 1, :) = linspace(26.5, 40, 11);

dx = 0.5;
dy = dx;

x(:, 1, 1) = -50:dx:50;
y(1, :, 1) = -40:dy:40;

biX = 1;

%% Create SAR Data
% Example 1: Single target in center
% Layer 1: er = 1, thk = 20 mm
% Layer 2: er = 20, thk = 20 mm
% Layer 3: er = 1, infinite half-space
x0_1 = [0];
y0_1 = [0];
z0_1 = [-30];
a0_1 = [1];
er1 = [1, 20, 1];
thk1 = [20, 20, inf];
S_1 = createSarData3d(x, y, f, x0_1, y0_1, z0_1, a0_1, ...
    Er=er1, Thk=thk1, ...
    BistaticSeparationX=biX);

% Example 2: Multiple targets, different depths
% Layer 1: er = 1, thk = 10 mm
% Layer 2: er = 3, thk = 10 mm
% Layer 3: er = 5, infinite half-space
x0_2 = [-20, 0, 20];
y0_2 = [0];
z0_2 = [-10, -20, -30];
a0_2 = [1];
er2 = [1, 3, 5];
thk2 = [10, 10, inf];
z_2 = -(0:1:40);
S_2 = createSarData3d(x, y, f, x0_2, y0_2, z0_2, a0_2, ...
    Er=er2, Thk=thk2, ...
    BistaticSeparationX=biX);

%% Perform SAR
Img_1_1 = sar3d(S_1, x, y, z0_1, f, ZeroPadPercent=25, Er=er1, Thk=thk1, ...
    BistaticSeparationY=biX);
Img_1_2 = sar3d(S_1, x, y, z0_1, f, ZeroPadPercent=25, ...
    BistaticSeparationX=biX);

Img_2_1 = sar3d(S_2, x, y, z_2, f, ZeroPadPercent=25, Er=er2, Thk=thk2, ...
    BistaticSeparationX=biX);
Img_2_2 = sar3d(S_2, x, y, z_2, f, ZeroPadPercent=25, ...
    BistaticSeparationX=biX);

Img_3_1 = sar3d(S_2, x, y, z_2, f, ZeroPadPercent=25, Er=er2, Thk=thk2, ...
    BistaticSeparationX=biX);
Img_3_2 = sar3d(S_2, x, y, z_2, f, ZeroPadPercent=25, Er=er2, Thk=thk2, ...
    BistaticSeparationX=0);

%% Plot
figure;
subplot(2, 1, 1);
showImage(x, y, Img_1_1, DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Correct Stackup");
subplot(2, 1, 2);
showImage(x, y, Img_1_2, DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Wrong Stackup");

figure;
subplot(2, 1, 1);
showImage(x, z_2, Img_2_1(:, y == 0, :), DisplayFormat="Magnitude");
colormap jet;
title("Example 2: Correct Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);
subplot(2, 1, 2);
showImage(x, z_2, Img_2_2(:, y == 0, :), DisplayFormat="Magnitude");
colormap jet;
title("Example 2: Wrong Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);

figure;
subplot(2, 1, 1);
showImage(x, z_2, Img_3_1(:, y == 0, :), DisplayFormat="Magnitude");
colormap jet;
title("Example 3: Correct Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);
subplot(2, 1, 2);
showImage(x, z_2, Img_3_2(:, y == 0, :), DisplayFormat="Magnitude");
colormap jet;
title("Example 3: Wrong Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);
