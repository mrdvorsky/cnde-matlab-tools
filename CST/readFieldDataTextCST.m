function [ Dx, Dy, Dz, x, y, z ] = readFieldDataTextCST( filename )
%READFIELDDATACST Read uniform electric or magnetic field data
%           from CST .bix file
%   Dx -> Field Data x-component (dimensions y,x,z)
%   Dy -> Field Data y-component (dimensions y,x,z)
%   Dz -> Field Data z-component (dimensions y,x,z)
%   x -> unique vector of x values
%   y -> unique vector of y values
%   z -> unique vector of z values

%% Read Data
allData = dlmread(filename, '', 2, 0);

%% Organize Data
x = allData(:, 1);
y = allData(:, 2);
z = allData(:, 3);
fieldData = allData(:, 4:9);
xNumChanges = sum(diff(x) ~= 0);
yNumChanges = sum(diff(y) ~= 0);
zNumChanges = sum(diff(z) ~= 0);
[~, dimOrder] = sort([xNumChanges; yNumChanges; zNumChanges], 'descend');
xFlip = x(1) ~= min(x);
yFlip = y(1) ~= min(y);
zFlip = z(1) ~= min(z);
x = unique(x);
y = unique(y);
z = unique(z);
sizesXYZ(:) = [length(x), length(y), length(z)];

fieldData = reshape(fieldData, [sizesXYZ(dimOrder), 6]);
fieldData = permute(fieldData, [dimOrder; 4]);

if xFlip
    fieldData = flip(fieldData, 1);
end
if yFlip
    fieldData = flip(fieldData, 2);
end
if zFlip
    fieldData = flip(fieldData, 3);
end

Dx = complex(fieldData(:, :, :, 1), fieldData(:, :, :, 4));
Dy = complex(fieldData(:, :, :, 2), fieldData(:, :, :, 5));
Dz = complex(fieldData(:, :, :, 3), fieldData(:, :, :, 6));

end

