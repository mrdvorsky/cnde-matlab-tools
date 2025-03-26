clc;
clear;
close all;

%% Inputs
x(:, 1) = 2 * linspace(-1, 1, 1000);
y(1, :) = 2 * linspace(-1, 1, 1000);

maxIter = 1000;

%% Compute Escape Time
c0 = x + 1j*y;
c = 0;
eTime = 0*c;
for ii = 0:(maxIter - 1)
    cNew = c.^2 + c0;
    eTime(abs(c) < 2 & abs(cNew) > 2) = ii;
    c = cNew;
end


figure;
showImage(x, y, reshape(eTime, 1000, 1000));




