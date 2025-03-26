function [ ImgOut, Xout, Yout ] = resampleImage( Img, X, Y, dx, dy )
%RESAMPLEIMAGE Resamples an image (and X,Y coords) to dx and/or dy
%   TODO: Write explanation

if nargin < 5
    if length(dx) > 1
        dy = dx(2);
        dx = dx(1);
    else
        dy = dx;
    end
end

scaleX = abs(X(2) - X(1)) ./ dx;
scaleY = abs(Y(2) - Y(1)) ./ dy;

[ImgOut, Xout, Yout] = upscaleImage(Img, X, Y, scaleX, scaleY);

end

