function [ ] = colormapVH( )

vec = linspace(0, 1, 91).';
vec = [vec; vec(end - 1:-1:1)];

colormap([vec, 1 - vec, 1 - vec]);

end

