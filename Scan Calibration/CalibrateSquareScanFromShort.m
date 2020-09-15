function [ ] = CalibrateSquareScanFromShort(filePath, calAppend)
%CALIBRATESQUARESCAN Creates a calibrated .mat file from a .scan and a
%   .s2p file

if nargin < 2
    calAppend = "";
end

CalibrateScanFromShort(filePath, calAppend, [1, 2]);

end

