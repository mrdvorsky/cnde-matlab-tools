clc;
clear;
close all;

%% Inputs
f = linspace(8.2, 12.4, 1000);

% Whether or not to create a second axis with priority, to test whether
% the "Axis" input can properly target non-active axes.
createUnusedFigureForTesting = true;

% Whether or not to update the image after 5 second, in order to test the
% "updateFun" functionality.
testUpdateFunctionAfterPause = true;

%% Create Data
v1(:, 1) = (f - 9 + 0.2j) .* exp(-0.5j .* f) ./ 15;
v2(:, 1) = f .* exp(-0.3j .* (f + pi)) ./ 19;
v3(:, 1) = (f - 11 + 0.4j) .* exp(-0.5j .* f) ./ 15;

%% Plotting
figure;
ax = gca();

% Test if the "Axis" input works properly by creating a new axis.
if createUnusedFigureForTesting
    figure;
    axUnused = gca();
end

[~, updateFun12] = plotComplex(f, [v1, v2], "", ...
    LineWidth=1.5, DisplayFormat="Polar", Axis=ax);
hold(ax, "on");
[~, updateFun3] = plotComplex(f, v3, "", ...
    LineWidth=1.5, DisplayFormat="Polar", Axis=ax);
grid(ax, "on");

% Test the "updateFun" functionality.
if testUpdateFunctionAfterPause
    pause(5);
    updateFun12(conj([v1, v2]));

    pause(1);
    updateFun3(conj(v3));
end
