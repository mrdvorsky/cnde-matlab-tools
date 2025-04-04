function [] = renameMatFileFields(filename)
%Rename fields in a ".mat" file.
% Helper utility function to rename fields in a ".mat" file. This normally
% involves loading the file, changing the field names, then saving. This
% is a GUI utility to streamline this process.
%
% Example Usage:
%   renameMatFileFields("matFile.mat");
%   renameMatFileFields("matFile");
%   renameMatFileFields matFile;
%
% Inputs:
%   filename - String with filename of a ".mat" file, with or without
%       the extension.
%
% Author: Matt Dvorsky

arguments
    filename(1, 1) string;
end

%% Load File
fileStruct = load(filename);

%% Create GUI
Old_Names = string(fieldnames(fileStruct));
New_Names = Old_Names;

fig = uifigure(HandleVisibility="on");
nameTable = uitable(fig, Units="normalized", Position=[0.1, 0.1, 0.8, 0.8], ...
    Data=table(Old_Names, New_Names), ColumnEditable=[false, true]);

fig.CloseRequestFcn = {@closeHandler, filename, fileStruct, nameTable};
uiwait(fig);

end


%% File Save Function
function closeHandler(src, ~, filename, fileStruct, nameTable)
    try
        oldNames = table2array(nameTable.Data(:, 1));
        newNames = table2array(nameTable.Data(:, 2));

        for ii = 1:numel(oldNames)
            fileStructNew.(newNames(ii)) = fileStruct.(oldNames(ii));
        end

        save(filename, "-struct", "fileStructNew");
    catch ex
        delete(src);
        rethrow(ex);
    end
    delete(src);
end




