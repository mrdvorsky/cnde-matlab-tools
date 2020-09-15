clc; clear all; close all;

[file,path] = uigetfile('*.*',  'All Files (*.*)','MultiSelect','on');
file = string(file);
figure; 
for jj = 1:numel(file)
    if (numel(file)>1)
        [fPath, fName, fExt] = fileparts(fullfile(path,file{jj}));
    else
        [fPath, fName, fExt] = fileparts(fullfile(path,file));
    end
    keep = sprintf("%s\\%s%s",fPath,fName,fExt);
    switch lower(fExt)
        % *.s1p
        case '.s1p'
            S11 = sparameters(keep);
            F = S11.Frequencies();
            S11m(jj,:) = squeeze(S11.Parameters());
            num = 1;        % *.s1p
        case '.nsnp'
            S11 = readNewNsnp(keep);
            F = S11.Frequencies();
            S11m = squeeze(S11.Data());
            num = 1;
        % *.grp.mat
        case '.mat'
            load(keep);
            if exist('vna_meas_data','var')
                F = vna_meas_data.Freq(:,1);
                S11m = mean(vna_meas_data.Data,2);
            else
                F = temp.Measurement_Data{2};
                S11m = temp.Measurement_Data{3};
            end
            num = size(S11m,2);
        otherwise 
            error('Unexpected file extension: %s', fExt);
    end

    plot(S11m(jj,:),'linewidth',2)
    hold on;
end
axis equal;

zplane([]);
axis([-1,1,-1,1])
save("5-20-X-panel3.mat","S11m");
