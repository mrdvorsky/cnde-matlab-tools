function [cst,mws] = openCST(filename)
    cst = actxserver('CSTStudio.Application.2019'); 
    mws = cst.invoke('NewMWS'); 
    mws.invoke('OpenFile',filename);   
end