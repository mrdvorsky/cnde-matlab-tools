clc;
clear;
close all;

%% Inputs
n = 5;

%% Generate A, B, D
A = rand(n, n) + 1j*rand(n, n);
B = rand(n, n) + 1j*rand(n, n);
D = diag(rand(n, 1) + 1j*rand(n, 1));

C = A*D + B;

lam2(1, :, 1) = eig(A*D + B);
lam3(1, 1, :) = lam2(:);
S = diag(lam2);

%% Guess eigenvectors
Dp = diag(lam2);

for ii = 1:10009
    [~, sing, V] = pagesvd(A*Dp + B - lam3.*eye(size(A)), "vector");
    Q(:, :, 1) = V(:, end, :);
    
    for jj = 1:size(Q, 2)
        A1{jj} = A .* Q(:, jj).';
        B1{jj} = (lam2(jj)*eye(size(A)) - B) * Q(:, jj);
    end
    An = cat(1, A1{:});
    Bn = cat(1, B1{:});

    d = An \ Bn;
    Dp = diag(d);
end

rms(abs(D - Dp), "all")
err = rms(An*d - Bn)

D
Dp
S

sort(eig(A*D + B)) - sort(eig(A*Dp + B))


