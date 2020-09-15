function viewSlices(Data,ViewType,coord)
	Opts.Colormap = jet(256);
    if nargin > 2
        Opts.SliceNumbers = coord;
    end
    cmap = jet(256);
    switch (ViewType)
        case "linear"
            sl = orthosliceViewer(abs(Data),Opts)
        case "log"
            sl = orthosliceViewer(db(abs(Data)),Opts);
        case "angle"
            sl = orthosliceViewer(angle(Data),Opts);
        case "real"
           sl = orthosliceViewer(real(Data),Opts);
        case "imag"
            sl = orthosliceViewer(imag(Data),Opts);
    end
    set(sl,'CrosshairEnable','off');
    [hXY hYZ hXZ] = getAxesHandles(sl);
    hXY.XTick = 10:10:floor(hXY.XLim(2));
    hXY.XTickLabel = 10:10:floor(hXY.XLim(2));
    
    hXY.YTick = 10:10:floor(hXY.YLim(2));
    hXY.YTickLabel = 10:10:floor(hXY.YLim(2));
    
    hXZ.XTick = 10:10:floor(hXZ.XLim(2));
    hXZ.YTick = 10:10:floor(hXZ.YLim(2));
    hXZ.YTickLabel = 10:10:floor(hXZ.YLim(2));
    hYZ.XTick = 10:10:floor(hYZ.XLim(2));
    hYZ.YTick = 10:10:floor(hYZ.YLim(2));
end