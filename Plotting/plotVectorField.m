function [] = plotVectorField(x, y, Ex, Ey, options)
%PLOTVECTORFIELD Summary of this function goes here
% 
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(1, :);
    Ex(:, :);
    Ey(:, :);
    options.PlotPhasesDeg(1, 1) = [0];
end

%% Decimate
decFacX = 25;
decFacY = 25;
% x = x(1:decFacX:end);
% y = y(1:decFacY:end);
% Ex = Ex(1:decFacX:end, 1:decFacY:end);
% Ey = Ey(1:decFacX:end, 1:decFacY:end);

%% Get Max Phase
phaseMax = 0.5 * angle(mean((Ex(:) + Ey(:)).^2));
options.PlotPhasesDeg = rad2deg(phaseMax);

%% Get Quiver Orientation
scaleMax = max(hypot(Ex(:), Ey(:)));
arrowScale = 0.4 * min(abs(x(2) - x(1)), abs(y(2) - y(1)));
for ii = 1:numel(options.PlotPhasesDeg)
    u = real(Ex .* exp(-1j .* deg2rad(options.PlotPhasesDeg(ii)))) ./ scaleMax;
    v = real(Ey .* exp(-1j .* deg2rad(options.PlotPhasesDeg(ii)))) ./ scaleMax;

    % subplot(1, 1, ii);
    showImage(x, y, hypot(u, v));
    clim([0, 1]);
    colormap gray;

    xq = x(1:decFacX:end);
    yq = y(1:decFacY:end);
    uq = u(1:decFacX:end, 1:decFacY:end) * min(decFacX, decFacY);
    vq = v(1:decFacX:end, 1:decFacY:end) * min(decFacX, decFacY);
    
    hold on;
    quiver(xq, yq, arrowScale*uq.', arrowScale*vq.', 0, "b", ...
        LineWidth=1.0, MaxHeadSize=100);
    hold on;
    quiver(xq, yq, -arrowScale*uq.', -arrowScale*vq.', 0, "b", ...
        LineWidth=1.0, ShowArrowHead="off");
    title(sprintf("Phase = %g deg", options.PlotPhasesDeg(ii)));
end




end

