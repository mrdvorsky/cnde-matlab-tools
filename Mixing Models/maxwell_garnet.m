function [er_eff] = maxwell_garnet(er, vf, eri)
%MAXWELL_GARNET Implementation of dielectric mixing model.
% 
% 
% Author: Matt Dvorsky

arguments
    er;
end
arguments (Repeating)
    vf {mustBeInRange(vf, 0, 1)};
    eri;
end
mustHaveCompatibleSizes(er, vf{:}, eri{:});

%% Calculate Effective Permittivity
sumVal = 0;
for ii = 1:numel(vf)
    sumVal = vf{ii} .* (eri{ii} - er) ./ (eri{ii} + 2*er);
end

er_eff = er + (3*er) .* sumVal ./ (1 - sumVal);

end

