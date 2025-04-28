function [ Img, varargout ] = sar3dRadialBackProj( S, x, y, z, f, varargin )
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

% Img = sar3dSlow(S, x, y, z, f, varargin{:});

% Img = Img ./ max(abs(Img(:)));

% [varargout{1:(nargout - 1)}] = processRadialImage(Img);

Img = zeros(length(x), length(y), length(z));
ImgL = zeros(size(Img));
ImgR = zeros(size(Img));

x1(:, 1, 1) = x(:);
y2(1, :, 1) = y(:);
z3(1, 1, :) = z(:);
k3(1, 1, :) = 2 .* pi .* f(:) ./ 300;
for xx = 1:length(x)
    for yy = 1:length(y)
        for zz = 1:length(z)
            [phi, ~, R] = cart2sph(-x1 + x1(xx), -y2 + y2(yy), -abs(z3(zz)));
            
            Scorr = S .* exp(2j .* k3 .* R);
            Img(xx, yy, zz) = sum(reshape(Scorr, [], 1));
            ImgL(xx, yy, zz) = sum(reshape(Scorr .* 2 .* exp(2j .* phi), [], 1));
            ImgR(xx, yy, zz) = sum(reshape(Scorr .* 2 .* exp(-2j .* phi), [], 1));
        end
    end
    disp(xx);
end

ImgMax = max(abs(Img(:)));
Img = Img ./ ImgMax;
ImgL = ImgL ./ ImgMax;
ImgR = ImgR ./ ImgMax;

% [ImgL, ImgR, ImgAng, ImgPr] = processRadialImage(Img);

ImgAng = abs(Img) .* exp(1j ...
    .* angle(ImgL ./ Img .* sqrt(Img.^2 ./ (ImgL .* ImgR))));

ImgP = 2 .* ImgL ./ (ImgAng ./ abs(ImgAng));
ImgN = Img - 0.5 .* ImgP;
ImgPr = abs(ImgP) ./ (abs(ImgP) + abs(ImgN));

varargout{1} = ImgL;
varargout{2} = ImgR;
varargout{3} = ImgAng;
varargout{4} = ImgPr;

end




