function [ ] = colormapError( )

ramp = linspace(0, 1, 91).';

r = [0*ramp + 1; flip(ramp)];
g = [0*ramp + 1; flip(ramp)];
b = [ramp; 0*flip(ramp) + 1];

colormap([0.5*sqrt(r), sqrt(g), sqrt(b)]);

end

