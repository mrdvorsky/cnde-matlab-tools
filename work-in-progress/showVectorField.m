function [] = showVectorField(x, y, Ex, Ey, options)
%SHOWVECTORFIELD Summary of this function goes here
% 
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(1, :);
    Ex(:, :);
    Ey(:, :);

    options.PlotPhasesDeg(:, 1) = 0;
    options.DecimationFactorX(1, 1) {mustBePositive} = 10;
    options.DecimationFactorY(1, 1) {mustBePositive} = 10;
end

%% Decimate
decFacX = options.DecimationFactorX;
decFacY = options.DecimationFactorY;

%% Get Quiver Orientation
scaleMax = sqrt(max(abs(Ex(:).^2 + Ey(:).^2)));
arrowScale = 0.7 * min(abs(x(2) - x(1)), abs(y(2) - y(1)));
for ii = 1:numel(options.PlotPhasesDeg)
    ExInst = real(Ex .* exp(-1j .* deg2rad(options.PlotPhasesDeg(ii))));
    EyInst = real(Ey .* exp(-1j .* deg2rad(options.PlotPhasesDeg(ii))));

    u = ExInst ./ scaleMax;
    v = EyInst ./ scaleMax;

    figure(Position=[100, 100, 800, 800]);
    showImage(x, y, hypot(u, v));
    clim([0, 1]);
    colormap gray;

    xq = x(1:decFacX:end);
    yq = y(1:decFacY:end);
    uq = u(1:decFacX:end, 1:decFacY:end) * min(decFacX, decFacY);
    vq = v(1:decFacX:end, 1:decFacY:end) * min(decFacX, decFacY);

    hold on;
    quiver(xq.' - arrowScale*uq.', yq.' - arrowScale*vq.', ...
        2*arrowScale*uq.', 2*arrowScale*vq.', 0, "b", ...
        LineWidth=0.8, MaxHeadSize=40);
    title(sprintf("Phase = %g deg", options.PlotPhasesDeg(ii)));
end




end

