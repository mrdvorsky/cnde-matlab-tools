clc;
clear;
close all;

%% Inputs
x(:, 1) = 15 * linspace(-1, 1, 350);
y(1, :) = 10 * linspace(-1, 1, 250);

% Whether or not to create a second axis with priority, to test whether
% the "Axis" input can properly target non-active axes.
createUnusedFigureForTesting = true;

% Whether or not to update the image after 5 second, in order to test the
% "updateFun" functionality.
testUpdateFunctionAfterPause = true;

%% Calculate Image
r = hypot(x, y);
phi = atan2(y, x);

Img = besselh(1, 2, r) .* cos(phi - pi/4) .* (r > 1);

%% Plotting
figure;
ax = gca();

% Test if the "Axis" input works properly by creating a new axis.
if createUnusedFigureForTesting
    figure;
    axUnused = gca();
end

[~, updateFun] = showImage(x, y, Img, DisplayFormat="Magnitude", Axis=ax);

% Test the "updateFun" functionality.
if testUpdateFunctionAfterPause
    pause(5);
    updateFun(conj(Img));
end
