clc;
clear;
close all;

%% Inputs
dx = 1;
dy = dx;

x(:, 1, 1) = -200:dx:200;
y(:, 1, 1) = -200:dy:200;

c = 299.792468;
f = 30;

z0 = -50;
biX = 50;

%% Create SAR Data
S = createSarData3d(x, y, f, 0, 0, z0, 1, BistaticSeparationX=biX);

%% Create Multistatic Matrix











