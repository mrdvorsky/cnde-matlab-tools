function [ ] = SquareCalGenerateAdapter( filename, varargin )


%% Inputs
filenames = ["s", "s1", "s2", "s3", "load"];
filePaths = compose(strcat(filename, "/%s.s2p"), filenames);

calFileOut = strcat(filename, "/calData");

% Shorts are 30.75, 60.0, and 129.5 mils respectively
shortLengths(1, 1, :, 1) = [0, 30.3, 60, 130, 0] .* 0.0254;

wg_a = 7.112;
c = 299.79;

g1Guess = exp(1j .* deg2rad(-20));
g2Guess = exp(1j .* deg2rad(20));

calIndices = [1, 2:5];

%% Manage Inputs
if nargin == 1
    plotIndices = [];
else
    plotIndices = [1:4];
end

%% Read Data
SpTmp = readSnp(filePaths(1));
F = SpTmp.Frequencies;
Sm = zeros([size(SpTmp.Parameters), length(filePaths)]);
Sm = permute(Sm, [1, 2, 4, 3]);

for ii = 1:length(filePaths)
    SpTmp = readSnp(filePaths(ii));
    Sm(:, :, ii, :) = SpTmp.Parameters;
end

%% Calculate Cal Standard S-parameters
k(1, 1, 1, :) = 2 .* pi .* F ./ c;
kz = sqrt(k.^2 - (pi ./ wg_a).^2);
d = exp(-2j .* kz .* shortLengths);

%% Find Calibration Parameters
Tcirc = zeros(2, 2, 4, length(F));
Tlin = zeros(2, 2, 4, length(F));
g1 = zeros(length(F), 1);
g2 = zeros(length(F), 1);
for ff = 1:length(F)
    [Tlin(:, :, :, ff), Tcirc(:, :, :, ff), g1(ff), g2(ff)] = SquareCalGetErrorParams(...
        Sm(:, :, calIndices, ff), d(1, 1, calIndices, ff), g1Guess, g2Guess, -1j);
    g1Guess = g1(ff);
    g2Guess = g2(ff);
end

%% Apply Calibration
Scal = 0*Sm;
for ff = 1:length(F)
    for ii = 1:size(Sm, 3)
        Scal(:, :, ii, ff) = NPortCal(Sm(:, :, ii, ff), Tcirc(:, :, :, ff));
    end
end

%% Plot Gamma's
if ~isempty(plotIndices)
    figure;
    plots(F, 180 ./ pi .* unwrap(angle(-g1)), "Linewidth", 2);
    hold on;
    plots(F, 180 ./ pi .* unwrap(angle(-g2)), "Linewidth", 2);
end

%% Plot Smm Results
if ~isempty(plotIndices)
    figure;
    for ii = 1:length(plotIndices)
        plots(F, rad2deg(unwrap(angle(Scal(1, 2, plotIndices(ii), :)))), "Linewidth", 2);
        hold on;
        plots(F, rad2deg(unwrap(angle(d(1, 1, plotIndices(ii), :)))));
    end
end

%% Plot Smn Results
if ~isempty(plotIndices)
    figure;
    for ii = 1:length(plotIndices)
        plots(F, (db(Scal(1, 1, plotIndices(ii), :))), "Linewidth", 2);
        hold on;
        plots(F, (db(Scal(2, 2, plotIndices(ii), :))), "Linewidth", 2);
        ylim([-60, 0]);
        %     xlim([-inf, 30]);
    end
end

%% Save Tcal to File
save(calFileOut, "Tlin", "Tcirc", "F");



end

