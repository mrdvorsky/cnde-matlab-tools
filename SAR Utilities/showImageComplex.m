function [varargout] = showImageComplex(x, y, Img, varargin)
%SHOWIMAGECOMPLEX Shows an xy complex-valued image using color for phase.
% This function is simply a wrapper around showImage, but with the
% DisplayFormat defaulted to "MagPhase". See documentation of showImage for
% more details.
%
% Example Usage:
%   showImageComplex(x, y, Img);
%   h = showImageComplex(x, y, Img);
%   showImageComplex(x, y, Img, NormalizeFactor=1.5);
%   showImageComplex(x, y, Img, PhaseMultiplier=0.5);

[varargout{1:nargout}] = showImage(x, y, Img, varargin{:}, DisplayFormat="MagPhase");

end

