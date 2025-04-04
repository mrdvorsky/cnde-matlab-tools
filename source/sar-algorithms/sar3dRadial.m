function [ Img, varargout ] = sar3dRadial( S, x, y, z, f, varargin )
%SAR3DRADIAL Generate polarized images from radial sar data
%   S -> Raw Data
%   x -> x coordinates
%   y -> y coordinates
%   z -> Desired z coordinates
%   f -> Freqeuncy coordinates
%   zx -> (Optional) Zero pad amount x (percent)
%   zy -> (Optional) Zero pad amount y (percent)
%
%   Img -> SAR image generated using standard SAR algorithm. This image
%       represents the circularly polarized cross-pol image.
%   ImgL -> Like-pol left-hand circularly polarized SAR image
%   ImgR -> Like-pol right-hand circularly polarized SAR image
%   ImgAng (Optional) -> Image showing magnitude (gamma) and orientation
%       (theta). Represented as abs(Img) .* exp(2j .* theta).

Img = sar3dSlow(S, x, y, z, f, varargin{:});

Img = Img ./ max(abs(Img(:)));

[varargout{1:(nargout - 1)}] = processRadialImage(Img);

end




