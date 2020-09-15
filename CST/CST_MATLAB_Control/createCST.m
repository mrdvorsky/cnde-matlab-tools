function [cst,mws] = createCST()
    cst = actxserver('CSTStudio.Application.2019'); 
    mws = cst.invoke('NewMWS'); 
    [file,path] = uiputfile('*.cst');
    mws.invoke('FileNew');
    mws.invoke('SaveAs',[path  file],1);   
end