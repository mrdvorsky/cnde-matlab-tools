function [T, et, Refl, Refl2] = TRLCal(Thru, Line, R1, R2, Re)
%TRLCAL Perform a TRL calibration
% 
% Thru - Full 2-port measurement of Thru (size 2-by-2)
% Line - Full 2-port measurement of unknown but matched Line (Line length
%    should be less than half a lambda) (size 2-by-2)
% R1 - S11 for Unknown reflect (scalar)
% R2 - S22 for Unknown reflect (reflect same as for R1) (scalar)
% Re - Estimated ideal S11 value for the reflect. Only phase of this value
%    is important. Phase must be known within +-90 degrees.
%
% T - Error adapter for the measurement system. T is 2-by-2-by-4 and 
%    represents the four parameters in the equation
%    T1*S + T2 - Sm*T3*S - Sm*T4 = 0
%    Use the equation below to get actual S from measured Sm
%    S = (T1 - Sm*T3)\(Sm*T4 - T2)
% et - The calculated complex transmission coefficient of the unknown line
% Refl - The calculated complex reflection coefficient of the unknown
%    reflect

%% Inputs
if nargin < 5
    Re = -1;
end

%% Convert to T-parameters
Tt = [-det(Thru), Thru(1, 1); -Thru(2, 2), 1] ./ Thru(2, 1);
Td = [-det(Line), Line(1, 1); -Line(2, 2), 1] ./ Line(2, 1);

%% Calculate first set of parameters (b, (a/c), TLine)
Tdt = Td / Tt;
tRoots = roots([Tdt(2, 1), Tdt(2, 2) - Tdt(1, 1), -Tdt(1, 2)]);

for ii = 1:2
    b = tRoots(1);
    aOverC = tRoots(2);
    
    % y = j*sqrt(-x) gives the imaginary principle square root
    %  (imag(y) > 0) instead of the real (real(y) > 0). This ensures the
    %  phase range of et is 0 to 180 deg instead of -90 to 90 deg
    et = 1j .* sqrt(-(Tdt(1, 2) ./ aOverC + Tdt(1, 1)) ...
        ./ (Tdt(2, 1) .* b + Tdt(2, 2)));
    
    % Make sure et is represents a lossy line (abs(et) < 1). If not, swap
    %  the values of b and aOverC
    if abs(b) < abs(aOverC) % abs(et) < 1
        break;
    end
    tRoots = flip(tRoots);
end

%% Calculate (gamma, (beta/alpha), (a*alpha), (a/alpha))
d = -det(Thru);
e = Thru(1, 1);
f = -Thru(2, 2);
g = Thru(2, 1);

gamma = (f - d ./ aOverC) ./ (1 - e ./ aOverC);
betaOverAlpha = (e - b) ./ (d - b .* f);
aAlpha = (d - b .* f) ./ (1 - e ./ aOverC);
aOverAlpha = (R1 - b) .* (1 + R2 .* betaOverAlpha) ...
    ./ (R2 + gamma) ./ (1 - R1 ./ aOverC);

%% Calculate third set of parameters (a, c, Refl)
a = [1, -1] .* sqrt(aOverAlpha .* aAlpha);
c = a ./ aOverC;
Refl = (R1 - b) ./ (a - c .* R1);
disp(Refl)

% There are two possible values for a ( a = +-sqrt(...) ). We will
%  choose the value that gets our calculated reflection coefficient
%  of the unknown reflect (Refl) as close as possible to the estimated
%  reflect value (Re)
[~, minIndex] = min(abs(Refl - Re));
[~, maxIndex] = max(abs(Refl - Re));
a = a(minIndex);
c = c(minIndex);
disp([minIndex, maxIndex])
Refl2 = Refl(maxIndex);
Refl = Refl(minIndex);
disp([Refl, Refl2])


%% Calculate last set of parameters (alpha, beta, k);
alpha = (d - b .* f) ./ a ./ (1 - e ./ aOverC);
beta = alpha .* betaOverAlpha;
k = g ./ (alpha - f .* beta);

%% Construct calibration matrix (Tcal)
T(:, :, 1) = [a, 0; 0, k .* alpha];
T(:, :, 2) = [b, 0; 0, -k .* gamma];
T(:, :, 3) = [c, 0; 0, -k .* beta];
T(:, :, 4) = [1, 0; 0, k];


end

