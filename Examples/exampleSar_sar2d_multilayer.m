% This example file shows how to use sar2d to create SAR images of a
% multilayer structure.
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
er1 = [1, 20, 1];
thk1 = [20, 20, inf];
S_1 = createSarData2d(x, f, x0_1, z0_1, a0_1, Er=er1, Thk=thk1);

% Example 2: Multiple targets, different depths
x0_2 = [-20, 0, 20];
z0_2 = [-30, -50, -70];
a0_2 = [1];
er2 = [1, 3, 20];
thk2 = [30, 20, inf];
S_2 = createSarData2d(x, f, x0_2, z0_2, a0_2, Er=er2, Thk=thk2);

% Example 3: Same as example 2, but no magnitude decay with range
S_3 = createSarData2d(x, f, x0_2, z0_2, a0_2, Er=er2, Thk=thk2, ...
    UseRangeForAmplitude=false);

%% Perform SAR
Img_1_1 = sar2d(S_1, x, z, f, ZeroPadPercent=25, Er=er1, Thk=thk1);
Img_1_2 = sar2d(S_1, x, z, f, ZeroPadPercent=25);

Img_2_1 = sar2d(S_2, x, z, f, ZeroPadPercent=25, Er=er2, Thk=thk2);
Img_2_2 = sar2d(S_2, x, z, f, ZeroPadPercent=25);

Img_3_1 = sar2d(S_3, x, z, f, ZeroPadPercent=25, Er=er2, Thk=thk2);
Img_3_2 = sar2d(S_3, x, z, f, ZeroPadPercent=25);

%% Plot
figure;
subplot(2, 1, 1);
showImage(x, z, Img_1_1, DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Correct Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk1(1:end - 1)), ":w", Linewidth=1.5);
subplot(2, 1, 2);
showImage(x, z, Img_1_2, DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Wrong Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk1(1:end - 1)), ":w", Linewidth=1.5);

figure;
subplot(2, 1, 1);
showImage(x, z, Img_2_1, DisplayFormat="Magnitude");
colormap jet;
title("Example 2: Correct Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);
subplot(2, 1, 2);
showImage(x, z, Img_2_2, DisplayFormat="Magnitude");
colormap jet;
title("Example 2: Wrong Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);

figure;
subplot(2, 1, 1);
showImage(x, z, Img_3_1, DisplayFormat="Magnitude");
colormap jet;
title("Example 3: Correct Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);
subplot(2, 1, 2);
showImage(x, z, Img_3_2, DisplayFormat="Magnitude");
colormap jet;
title("Example 3: Wrong Stackup");
xlabel("x, mm");
ylabel("z, mm");
hold on;
plot([min(x), max(x)], [0; 0] + -cumsum(thk2(1:end - 1)), ":w", Linewidth=1.5);



