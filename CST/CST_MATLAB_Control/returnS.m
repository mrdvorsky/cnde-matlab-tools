function S = returnS(mws,ports)
    for ii = 1:ports
        for jj = 1:ports
            S(ii,jj) = invoke(mws, 'SelectTreeItem',sprintf("Tables\\1D Results\\S-Parameters\\S%i,%i",ii,jj));
            if ~S(ii,jj)
                disp(sprintf("Error Opening S(%s,%s)",ii,jj))
            end
        end
    end
end

