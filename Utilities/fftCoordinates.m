function [varargout] = fftCoordinates(xVectors, options)
%FFTCOORDINATES Returns spectral/spatial coordinates of fft output.
% Given the spatial/spectral coordinates of the input to the fft/ifft
% function, returns the spectral/spatial coordinates of the output. Works
% for multidimensional fft/ifft.
%
% If "x" contains the spatial coordinates of the vector "f", then the
% spectral coordinates of "F = fft(f)" will be returned as "k". If the
% "ApplyFftShift" named argument is set to true, then "k" will be the
% coordinates of "F_shifted = fftshift(fft(f))" instead.
%
% This function works for ifft as well. In this case, the spectral
% coordinates will be the input to this function, and the spatial
% coordinates will be the output.
%
% By default, the range of "k" will be [-kMax/2, kMax/2). However, if the
% "PositiveOutput" named argument is set to true, then the range will be
% converted to [0, kMax) by wrapping.
%
% Example Usage:
%   [k] = fftCoordinates(x);
%   [kx, ky] = fftCoordinates(x, y);
%   [kx, ky, ...] = fftCoordinates(x, y, ...);
%   [kx, ky, ...] = fftCoordinates(x, y, ..., ApplyFftShift=true);
%   [kx, ky, ...] = fftCoordinates(x, y, ..., PositiveOutput=true);
%
% Inputs:
%   xVectors (Repeating) - Vector of spatial coordinates. Must be
%       uniformly-spaced and sorted 
% Outputs:
%   kVectors (Repeating) - Vector of spectral coordinates. The dimension
%       of the vector will be the same as the positional index.
%
% Named Arguments:
%   ApplyFftShift (false) - If true, the output coordinates will be that
%       of "fftshift(fft(...))", instead of the default "fft(...)".
%   PositiveOutput (false) - If true, the output ranges will be [0, kMax)
%       instead of the default [-kMax/2, kMax/2).
%
% Author: Matt Dvorsky

arguments (Repeating)
    xVectors(:, 1) {mustBeReal, mustBeFinite};
end

arguments
    options.ApplyFftShift(1, 1) logical = false;
    options.PositiveOutput(1, 1) logical = false;
end

%% Compute Spectral Coordinates
varargout = cell(min(numel(xVectors), max(1, nargout)), 1);
for ii = 1:numel(varargout)
    N = numel(xVectors{ii});

    if N < 2
        varargout{ii} = zeros(N, 1);
    else
        dx = abs(xVectors{ii}(2) - xVectors{ii}(1));
        ix = 0:2:(2*N - 1);
        if ~options.PositiveOutput
            ix(ix >= N) = ix(ix >= N) - 2*N;
        end
        
        varargout{ii} = reshape(pi * ix ./ (N * dx), ...
            [ones(1, ii - 1), N, 1]);
    end
end

%% Apply FFTshift
if options.ApplyFftShift
    for ii = 1:numel(varargout)
        varargout{ii} = fftshift(varargout{ii});
    end
end

end

