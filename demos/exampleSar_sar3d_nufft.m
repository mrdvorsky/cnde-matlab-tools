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
dz = 1;

x(:, 1, 1) = -50:dx:50;
y(1, :, 1) = -40:dy:40;
z(1, 1, :) = -(0:dz:50);

%% Create SAR Data
% Example 1: Single target in center
x0_1 = [0];
y0_1 = [0];
z0_1 = [-50];
a0_1 = [1];
S_1 = createSarData3d(x, y, f, x0_1, y0_1, z0_1, a0_1);

%% Perform SAR
tic;
Img_1 = sar3d_nufftn(S_1, x, y, z, f, ZeroPadPercent=0);
toc;

tic;
Img_1 = sar3d(S_1, x, y, z, f, ZeroPadPercent=0);
toc;

%% Plot
figure;
showImage(x, y, Img_1(:, :, end), DisplayFormat="Magnitude");
colormap jet;
title("Example 1: Single Target");





