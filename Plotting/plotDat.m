clc; clear all; close all;

[file,path] = uigetfile('*.*',  'All Files (*.*)','MultiSelect','on');

figure; 
for jj = 1:numel(file)
    if (numel(file)>1)
        [fPath, fName, fExt] = fileparts(fullfile(path,file{jj}));
    else
        [fPath, fName, fExt] = fileparts(fullfile(path,file));
    end
    
    switch lower(fExt)
        % *.s1p
        case '.s1p'
            S11m = readSnp(fullfile(path,file{jj}));
            F = S11m.Frequencies();
            S11m = squeeze(S11m.Parameters());
            num = 1;
        % *.grp.mat
        case '.mat'
            temp = load(fullfile(path,file{jj}));
            F = temp.Measurement_Data{2};
            S11m = temp.Measurement_Data{3};
            num = size(S11m,2);
        otherwise 
            error('Unexpected file extension: %s', fExt);
    end
    
    for ii = 1:num
        txt = ['Measurement #',num2str(ii)];
        plot(S11m(:,ii),'linewidth',2,'DisplayName',txt)
        hold on;
    end
end
axis equal;
zplane([]);
axis([-1,1,-1,1])
