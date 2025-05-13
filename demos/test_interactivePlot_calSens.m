clc;
clear;
close all;

%% Inputs
S = [1, -1, exp(0.5j)];
% S = [S, 0.5*S];

% offInds = [1];
offInds = [1, 2, 3];
dt = 0.0001;

%% Create Plot Info
xp(:, 1) = linspace(-1.1, 1.1, 501);
yp(1, :) = linspace(-1.1, 1.1, 501);

%% Get Calibration Function
calSens = getCalSens(xp, yp, S, offInds);

%% Plot
figure;
handle_r = showImage(xp, yp, calSens, DisplayFormat="Magnitude");
clim([0, 2]);
hold on;
interactiveDots(real(S), imag(S), ...
    {@updatePlot, xp, yp, handle_r, offInds, dt}, ...
    MarkerSize=20, ...
    DragClampFun=@(x, y) [x, y] ./ max(hypot(x, y), 1));





%% Helper Functions
function [calOffset] = solveOffset(x, y, S, Sm)
    arguments
        x(1, 1, 1, 1, :, 1);
        y(1, 1, 1, 1, 1, :);
        S(1, 1, 1, :);
        Sm(1, 1, 1, :);
    end

    T = solveCalibrationModel(S, Sm);
    calOffset = squeeze(applyInverseCalibration(T, x + 1j*y) - (x + 1j*y));
end

function [calSens] = getCalSens(x, y, S, inds, dt)
    arguments
        x(:, 1);
        y(1, :);
        S(:, 1);
        inds(:, 1) = [1];
        dt(1, 1) = 0.0001;
    end
    
    calSens = 0;
    for ii = 1:numel(inds)
        Sm = S;
        Sm(inds(ii)) = Sm(inds(ii)) + dt;
        calSens = calSens + abs(solveOffset(x, y, S, Sm) ./ dt).^2;
    end
    calSens = sqrt(calSens) .* (hypot(x, y) <= 1);
end

function [sReal, sImag] = updatePlot(sReal, sImag, ind, xp, yp, plot_handle, offInds, dt)
    arguments
        sReal(:, 1);
        sImag(:, 1);
        ind(1, 1);
        xp(:, 1);
        yp(1, :);
        plot_handle;
        offInds(:, 1) = 1;
        dt(1, 1) = 0.0001;
    end

    calSens = getCalSens(xp, yp, sReal + 1j*sImag, offInds, dt);
    plot_handle.CData = calSens.';
end



