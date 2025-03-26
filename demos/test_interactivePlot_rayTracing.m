clc;
clear;
close all;

%% Inputs
x(:, 1) = -30:0.1:30;
z(1, :) =  -(0:0.1:80);

k = 2*pi;

xAnt(1, :) = linspace(-20, 20, 2);
 
% numLayers
% thk = (1:numel(er)).^(0.5);
% thk = thk ./ sum(thk) .* max(abs(z));

er = [1, 16];
thk = [10, inf];
thk(end) = max(abs(z)) - sum(thk(1:end-1));

tableSizePsi = 1000;
tableDr = 0.1;

x0 = 0;
z0 = -5;

%% Create Snells Law Lookup Table
tic;
ior(1, :) = sqrt(er);

psi = zeros(tableSizePsi, numel(thk));
psi(:, 1) = (0:tableSizePsi - 1) .* (0.5*pi) ...
    ./ tableSizePsi;
for ii = 2:numel(er)
    psi(:, ii) = asin(ior(ii - 1) ./ ior(ii) .* sin(psi(:, ii - 1)));
end

% Create refraction lookup table for each liftoff.
zLayerEnd = cumsum(thk);
xLayerEnd = cumsum(thk .* tan(psi), 2);
xTable_psiZ = 0 * psi(:, 1) .* z;
zLayerInd = 1 + sum(abs(z(:)) > zLayerEnd, 2).';
for tt = 1:numel(thk)
    zCurrentLayer = zLayerInd == tt;
    xTable_psiZ(:, zCurrentLayer) = xLayerEnd(:, tt) ...
        - tan(psi(:, tt)) .* (zLayerEnd(tt) - abs(z(zCurrentLayer)));
end

rs = 0:tableDr:(max(x) - min(x));
for zz = flip(2:numel(z))
    phiTable_xz(:, zz) = interp1(xTable_psiZ(:, zz), psi(:, 1), rs, "spline");
end
phiTable_xz(:, 1) = pi/2;

psiInterp = griddedInterpolant({rs, abs(z)}, phiTable_xz, "spline");
toc;

% [ray_r, ray_psi] = computeRayTrace(x, z, 0, cumsum(abs(thk(1:end-1))), er);

%% Create Ray Lines
[ray_x, ray_z] = computeRayLines(xAnt, x0, z0, psiInterp, ior, thk);

Img = computeWaves(x, z, x0, z0);

%% Plot
figure;
imgHandle = showImage(x, z, Img, DisplayFormat="Real");
colormap colormapPlusMinus;
clim([-0.2, 0.2]);
hold on;
rayHandles = plot(ray_x.', -ray_z.', "w", LineWidth=0.1);
xlim([min(x), max(x)]);

for ii = 1:numel(thk) - 1
    plot(xlim(), [0, 0] - zLayerEnd(ii), "y:", LineWidth=0.1);
end

interactivePlot(x0, z0, ...
    {@updateFun, rayHandles, imgHandle, xAnt, psiInterp, ior, thk}, ...
    MarkerSize=20);



%% Helper Functions
function [ray_x, ray_z] = computeRayLines(xAnt, x0, z0, psiInterp, ior, thk)
    ray_psi = psiInterp({abs(xAnt - x0), abs(z0)}) .* sign(xAnt(:) - x0);

    for ii = 2:numel(ior)
        ray_psi(:, ii) = asin(ior(ii - 1) ./ ior(ii) .* sin(ray_psi(:, ii - 1)));
    end
    ray_x = cumsum([xAnt(:), -thk(:).' .* tan(ray_psi)], 2);
    ray_z = 0*ray_x + cumsum([0, thk(:).']);

    isHigher = ray_z > abs(z0);
    ray_z = min(ray_z, abs(z0));
    ray_x = ray_x .* ~isHigher + isHigher*x0;
end

function [Img] = computeWaves(x, z, x0, z0)
    R = hypot(x(:) - x0, z(:).' - z0);
    Img = besselj_spherical(0, 2*pi .* R);
end

function [x0, z0] = updateFun(x0, z0, ind, rayHandles, imgHandle, xAnt, psiInterp, ior, thk)
    [ray_x, ray_z] = computeRayLines(xAnt, x0, z0, psiInterp, ior, thk);
    for ii = 1:size(ray_x, 1)
        rayHandles(ii).XData = ray_x(ii, :);
        rayHandles(ii).YData = -ray_z(ii, :);
    end

    x = imgHandle.XData;
    z = imgHandle.YData;
    imgHandle.CData = real(computeWaves(x, z, x0, z0).');
end




