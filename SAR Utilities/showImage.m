function [ varargout ] = showImage( x, y, Img, varargin )
%SHOWIMAGE Shows an xy image by squeezing the inputs and tranposing Img

[varargout{1:nargout}] = imagesc(squeeze(x), squeeze(y), squeeze(Img).', varargin{:});
axis image;
axis xy;

end

