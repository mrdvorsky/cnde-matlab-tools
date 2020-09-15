function [ ImgOut, Xout, Yout ] = upscaleImage( Img, X, Y, scaleX, scaleY )
%UPSCALEIMAGE Upscales an image (and X,Y coords) by scaleX and/or scaleY
%   TODO: Write explanation

if nargin < 5
    if length(scaleX) > 1
        scaleY = scaleX(2);
        scaleX = scaleX(1);
    else
        scaleY = scaleX;
    end
end

Xout = zeros(round((size(X) - 1) * scaleX + 1));
Yout = zeros(round((size(Y) - 1) * scaleY + 1));

Xout(:) = linspace(X(1), X(end), length(Xout));
Yout(:) = linspace(Y(1), Y(end), length(Yout));

ImgOut = imresize(Img, [length(Xout), length(Yout)]);

end

