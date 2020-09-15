clc; clear all; close all;
[file,path] = uigetfile("*.cst");
[cst,mws] = openCST([path file]);
S = returnS(mws,1); % this simulation has 1 port