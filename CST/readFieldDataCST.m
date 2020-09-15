function [ Dx, Dy, Dz, x, y, z ] = readFieldDataCST( filename )
%READFIELDDATACST Read uniform electric or magnetic field data
%           from CST .bix file
%   Dx -> Field Data x-component (dimensions y,x,z)
%   Dy -> Field Data y-component (dimensions y,x,z)
%   Dz -> Field Data z-component (dimensions y,x,z)
%   x -> unique vector of x values
%   y -> unique vector of y values
%   z -> unique vector of z values

regExpHeaderSize = 'HeaderBytes\s*=\s*([0-9]+);';
regExpDataSize = 'DataFieldBytes\s*=\s*([0-9]+);\s*([0-9]+);';

fileID = fopen(filename);

%% Parse Header
while true % Search for header size
    [tokens] = regexp(fgetl(fileID), regExpHeaderSize, 'tokens');
    if ~isempty(tokens)
        break
    end
end
hSize = str2double(tokens{1}{1});

% Search for data size (read the rest of the header)
[tokens] = regexp(fread(fileID, hSize - ftell(fileID), 'uint8=>char').', ...
    regExpDataSize, 'tokens');

posSize = str2double(tokens{1}{1}) / 8;
dataSize = str2double(tokens{1}{2}) / 4;

%% Read Data
posData = fread(fileID, posSize, 'double'); % Position Data (x,y,z)
fieldData = fread(fileID, dataSize, 'float');
% disp(posData(end-10:end))
% disp(fieldData(1:100));

fclose(fileID);

%% Organize Data
x = posData(1:3:end);
y = posData(2:3:end);
z = posData(3:3:end);
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

fieldData = reshape(fieldData, [6, sizesXYZ(dimOrder)]);
fieldData = permute(fieldData, [1 + dimOrder; 1]);

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

