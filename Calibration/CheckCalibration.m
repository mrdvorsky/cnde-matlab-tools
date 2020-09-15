% AMNTL -- Anna Case -- 2020
% Compares a calibration standard measurement to the theoretical value
clc; clear all; close all

[file,path] = uigetfile; % User loads measurement
[fPath, fName, fExt] = fileparts(fullfile(path,file));
switch lower(fExt)
    % *.s1p
    case '.s1p'
        S11m = readSnp(fullfile(path,file));
        F = S11m.Frequencies();
        S11m = squeeze(S11m.Parameters());
        if (F(1) == 12.4)
            kc = pi/15.7988;
        elseif (F(end) == 12.4)
            kc = pi/22.86;
        else
            disp("Frequency Band Not Recognized. Exiting Program.")
            return;
        end
        CalStandard = input(["Which measurement is this? 1)short 2)shifted short 3)load \n"]);
        if (CalStandard<1) || (CalStandard>3)
              disp(["This calibration standard is not recognized. Exiting program"]);
              return;
        end
        if (CalStandard == 2)
            Len = input("What is the length of the shifted short? (ex. 5) \n");
            disp(["Shift length: " num2str(Len) " mm"]);
        else
            Len = 0;
        end
        num = 1;
    % *.grp.mat
    case '.mat'
        temp = load(fullfile(path,file));
        F = temp.Measurement_Data{2};
        S11m = temp.Measurement_Data{3};
        num = size(S11m,2);
        if (F(1) == 12.4)
            kc = pi/15.7988;
        elseif (F(end) == 12.4)
            kc = pi/22.86;
        else
            disp("Frequency Band Not Recognized")
        end
        for ii = 1:num
            disp(["Measurement #" num2str(ii)])
            CalStandard(ii) = input("Which measurement is this? 1) short 2) shifted short 3) load \n");
            if (CalStandard(ii)<1) || (CalStandard(ii)>3)
                  disp("This calibration standard is not recognized. Exiting program");
                  return;
            end
            if (CalStandard(ii) == 2)
                Len(ii) = input("What is the length of the shifted short? (ex. 5) \n");
                disp(["Shift length: " num2str(Len(ii)) " mm"]);
            else
                Len(ii) = 0;
            end
        end
    otherwise 
        error('Unexpected file extension: %s', fExt);
end

%% Create theoretical values
if (F(1)>1000)
    k = 2*pi*F/3e11;
else
    k = 2*pi*F/300;
end
B = sqrt(k.^2-kc.^2);

figure;
for ii=1:num
    switch CalStandard
        case 1
            % Short
            S11t = -1*exp(-2j*B*Len(ii));
        case 2
            % Shifted Short
            S11t = -1*exp(-2j*B*Len(ii));
        case 3
            % Load
            S11t = zeros(numel(F),1);
        otherwise
            disp("Calibration standard is not recognized")
    end
    
    %% Plot the result
    res = db(abs(S11m-S11t));% dB difference between measured and theoretical
    txt = ['Measurement #',num2str(ii)];
    plot(F,res,'linewidth',2,'DisplayName',txt) 
    hold on;
    grid on
    xlabel("Frequency (Hz)");ylabel("dB Difference");
    title(sprintf("%s results, Calibration Standard #%i",file,CalStandard))
    
    figure; hold on;

    plot(S11t,'linewidth',5) 

    plot(S11m,'linewidth',2) 
    axis equal;
    zplane([]);
    axis([-1,1,-1,1])


end

