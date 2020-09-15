function [ X, Y, Header ] = readPlotDataCST( filePath )
%READPLOTDATACST Read plot data from CST export plot data
%   !!!! Be sure to select "as currently displayed" in the file  !!!!
%   !!!!    dialogue when exporting (Export - Plot Data ASCII),  !!!!
%   !!!!    i.e. DON'T select "as currently displayed (legacy)". !!!!
%   !!!!    If the legacy version is selected, header info will  !!!!
%   !!!!    not be parsed, but the plot data will still be read. !!!!
%   !!!!    Legacy format outputs real+imag as separate plots.   !!!!
%
%   If the file contains data from multiple plots, the plots must all have
%   the same size and X-axis values.

tmpData = readmatrix(filePath, "TreatAsMissing", "#");

if size(tmpData, 2) > 3 % Legacy version
    numPlots = round(sum(isnan(tmpData(:, 1))) ./ 2) + 1;
    data = reshape(tmpData(~isnan(tmpData(:, 1)), :), ...
        [], numPlots, size(tmpData, 2));
    
    X = data(:, 1, 1);
    Y = data(:, :, 2);
    
    Header.version = "Legacy";
else
    numPlots = round(sum(isnan(tmpData(:, 1))) ./ 3) + 1;
    data = reshape(tmpData(~isnan(tmpData(:, 1)), :), ...
        [], numPlots, size(tmpData, 2));
    
    X = data(:, 1, 1);
    if size(data, 3) >= 3
        Y = complex(data(:, :, 2), data(:, :, 3));
    else
        Y = data(:, :, 2);
    end
    
    Header.version = "Modern";
end

%% TODO: Add Functionally for reading header info
% fid = fopen(filePath);
% C = textscan(fid, "#%s", "Delimiter", "\n");
% fclose(fid);

end

