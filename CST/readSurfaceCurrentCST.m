function [ X, Y, Z, Data, A ] = readSurfaceCurrentCST( filename )
%READSURFACECURRENTCST Read uniform electric or magnetic field data
%           from CST .txt file
%   Data -> Field Data xyz-component (n-by-3 matrix)
%   X -> vector of x values
%   Y -> vector of y values
%   Z -> vector of z values
%   A -> vector of area values for each surface current measurement

%% Read Data
allData = dlmread(filename, '', 2, 0);

%% Organize Data
X = allData(:, 1);
Y = allData(:, 2);
Z = allData(:, 3);

Data = complex(allData(:, 4:6), allData(:, 7:9));

A = allData(:, 10);

end

