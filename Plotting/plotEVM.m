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
            S11 = readNewNsnp(fullfile(path,file{jj}));
            F = S11.Frequencies();
            S11m(jj,:) = squeeze(S11.Data());
            num = 1;        % *.s1p
        case '.nsnp'
            S11 = readNewNsnp(fullfile(path,file{jj}));
            F = S11.Frequencies();
            S11m = squeeze(S11.Data());
            num = 1;
        % *.grp.mat
        case '.mat'
            load(fullfile(path,file{jj}));
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
    

end

figure; hold on;
for ii= 1:2:jj
    EVM = db(S11m(ii,:)-S11m(ii+1,:));
    plot(F,EVM,'linewidth',2)
end
xlabel("Frequency");ylabel("EVM (dB)")
title("Measurement Differences"); grid on;
