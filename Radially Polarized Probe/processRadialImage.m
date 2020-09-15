function [ ImgL, ImgR, ImgAng, ImgPr ] = processRadialImage( Img )
%PROCESSRADIALIMAGE Generate circularly polarized images from radial image
%   TODO: Write description

[iy, ix] = freqspace([size(Img, 1), size(Img, 2)]);
ix = ifftshift(ix);
iy = ifftshift(iy);

ImgSpec = fft2(Img);
ImgSpecL = ImgSpec .* 2 .* ((ix.' + 1j*iy) ./ (ix.' - 1j*iy));
ImgSpecR = ImgSpec .* 2 .* ((ix.' - 1j*iy) ./ (ix.' + 1j*iy));
ImgSpecR(1, 1, :) = 0;
ImgSpecL(1, 1, :) = 0;

ImgL = ifft2(ImgSpecL);
ImgR = ifft2(ImgSpecR);

if nargout > 2
    ImgAng = abs(Img) .* exp(1j ...
        .* angle(ImgL ./ Img .* sqrt(Img.^2 ./ (ImgL .* ImgR))));
end

if nargout > 3
    ImgP = 2 .* ImgL ./ (ImgAng ./ abs(ImgAng));
    ImgN = Img - 0.5 .* ImgP;
    ImgPr = abs(ImgP) ./ (abs(ImgP) + abs(ImgN));
end

% ImgV = ImgL + ImgR - 2*Img;
% ImgH = ImgL + ImgR + 2*Img;

end

