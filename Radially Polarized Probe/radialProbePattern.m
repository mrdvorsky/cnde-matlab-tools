function [ magOut] = radialProbePattern(theta, theta0)

% a = exp(1);
% % b = 26.56 .* exp(-6.559 .* R0);
% x0 = 1.045 - 0.677 .* R0;
% x0 = R0;
% b = 0.0008596 .* exp(10 .* x0);
% 
% x = theta;
% magOut = a.*b.*sin(x) + a.*sin(x.*(1 + b./exp(1))./x0) ...
%     .* exp(-1./pi.*(x.*(1 + b./exp(1))./x0).^2);


x0 = theta0;
% x0 = 1.417 .* exp(-1.23 .* theta0); % If theta0 is horn radius

x = theta;

% magOut = exp(0.5).*(x./x0).*exp(-0.5.*(x./x0).^2); % Normalized to 1
magOut = 2.*(x./(x0.*sin(x0))).*exp(-0.5.*(x./x0).^2); % Total Rad Normalized

end

