function [ ImgOut, Xout, Yout, Fout ] = cropImage( Img, X, Y, F, xLim, yLim, fLim )
%UPSCALEIMAGE Crops image (and X,Y,Z/F coords) by to x/y/fLims
%   Img is numX-by-numY-by-numF-by-...
%   TODO: Write explanation

if nargin < 7
    fLim = [];
end

if isempty(xLim)
    xLim = [-inf, inf];
end
if isempty(yLim)
    yLim = [-inf, inf];
end
if isempty(fLim)
    fLim = [-inf, inf];
end

xLim = roundToNearest(xLim, X);
yLim = roundToNearest(yLim, Y);
fLim = roundToNearest(fLim, F);

xInd = find(X >= min(xLim) & X <= max(xLim));
yInd = find(Y >= min(yLim) & Y <= max(yLim));
fInd = find(F >= min(fLim) & F <= max(fLim));

sizeOut = size(Img);
sizeOut(1:3) = [length(xInd), length(yInd), length(fInd)];

Xout = X(xInd);
Yout = Y(yInd);
Fout = F(fInd);
ImgOut = Img(xInd, yInd, fInd, :);
ImgOut = reshape(ImgOut, sizeOut);

end

