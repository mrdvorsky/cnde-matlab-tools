function [ magOut] = antennaPatternGaussian( theta, thetaBw )
%ANTENNAPATTERN Axially-symmetric gaussian electric field antenna pattern
%   Electric field pattern of the form exp(-1.3863*(theta./thetaBw).^2)
%    theta - spherical coordinate for antenna pointing in +z direction
%    thetaBw - halfpower beamwidth (units the same as theta)

magOut = exp(-log(4)*(theta./thetaBw).^2);

end
