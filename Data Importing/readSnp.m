function [ Sp ] = readSnp( filename )
%READSNP Read .snp files

fHandle = fopen(filename);

% Read Header
portLabelExpression = 'Touchstone port [0-9]+ = (.*)';
unitExpression = '# (.*?) (.*?) (.*?) R (.*)';
Sp.PortLabels = [];
while true
    line = fgetl(fHandle);
    portToken = regexp(line, portLabelExpression, 'tokens');
    unitToken = regexp(line, unitExpression, 'tokens');
    if ~isempty(unitToken)
        Sp.FrequencyUnit = string(unitToken{1}{1});
        Sp.ParameterType = string(unitToken{1}{2});
        sFormat = string(unitToken{1}{3});
        Sp.Impedance = str2double(unitToken{1}{4});
        break;
    end
    if ~isempty(portToken)
        Sp.PortLabels = [Sp.PortLabels; string(portToken)];
    end
end
% Sp.NumPorts = length(Sp.PortLabels);

% Ignore lines starting with '!'
while true
    line = fgets(fHandle);
    if ~startsWith(line, "!")
        fseek(fHandle, -length(line), 0);
        break;
    end
end

% Read Data
sData = textscan(fHandle, '', -1, ...
    'EmptyValue', NaN, 'CollectOutput', true, 'EndOfLine', '\r\n');

fclose(fHandle);

sData = sData{1}.';
numF = sum(all(~isnan(sData)));
sData = reshape(sData(~isnan(sData(:))), [], numF);
Sp.Frequencies = sData(1, :).';
Sp.NumPorts = sqrt((size(sData, 1) - 1) ./ 2);
switch sFormat
    case 'DB'
        sData = 10.^(sData(2:2:end, :) ./ 20) .* ...
            exp(1j .* sData(3:2:end, :) .* pi ./ 180);        
    case 'MA'
        sData = sData(2:2:end, :) .* ...
            exp(1j .* sData(3:2:end, :) .* pi ./ 180);        
    case 'RI'
        sData = complex(sData(2:2:end, :), sData(3:2:end, :));
end
Sp.Parameters = reshape(sData, Sp.NumPorts, Sp.NumPorts, []);

end

