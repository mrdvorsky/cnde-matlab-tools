function [ Img, ImgL, ImgR, ImgAng, ImgPr ] = processCircularImage( ImgLL, ImgLR, ImgRL, ImgRR )
%PROCESSRADIALIMAGE Generate circularly polarized images from radial image
%   TODO: Write description


Img = 0.5*(ImgLR + ImgRL);
ImgL = ImgLL;
ImgR = ImgRR;

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

