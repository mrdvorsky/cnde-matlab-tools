clc;
clear;
close all;

%% Inputs
A = reshape(sym("a", [4, 1]), [2, 2]);
D = diag(sym("d", [2, 1]));
B = reshape(sym("b", [4, 1]), [2, 2]);

gam = sym("g");


charPol = A*D + B + gam*eye(2, 2);

det(charPol)
