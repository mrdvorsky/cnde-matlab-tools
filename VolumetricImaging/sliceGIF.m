function sliceGIF(Data,ViewType,filename,n,plane,coord)
    Opts.Colormap = jet(256);
    if nargin > 2
        Opts.SliceNumbers = coord;
    end
switch (ViewType)
    case "linear"
        sl = orthosliceViewer(abs(Data),Opts);
    case "log"
        sl = orthosliceViewer(db(abs(Data)),Opts);
    case "angle"
        sl = orthosliceViewer(angle(Data),Opts);
    case "real"
       sl = orthosliceViewer(real(Data),Opts);
    case "imag"
        sl = orthosliceViewer(imag(Data),Opts);
    case default
        disp("Unrecognized view type")
end
set(sl,'CrosshairEnable','off');
    [hXY hYZ hXZ] = getAxesHandles(sl);
    hXY.XTick = 10:10:floor(hXY.XLim(2));
    hXY.XTickLabel = 10:10:floor(hXY.XLim(2));
    hXY.YTick = 10:10:floor(hXY.YLim(2));
    hXY.YTickLabel = 10:10:floor(hXY.YLim(2));
    hXZ.ZTick = 10:10:floor(hXZ.ZLim(2));
    hXZ.ZTickLabel = 10:10:floor(hXZ.ZLim(2));
switch plane
    case "XY"
        [Axes, ~, ~] = getAxesHandles(sl);
    case "YZ"
        [~, Axes, ~] = getAxesHandles(sl);
    case "XZ"
        [~, ~, Axes] = getAxesHandles(sl);
    case default
        disp("Unrecognized plane");
end

for idx = n
    % Update slice number to get Slice.
    switch plane
        case "XY"
            sl.SliceNumbers(3) = idx;
        case "YZ"
            sl.SliceNumbers(2) = idx;
        case "XZ"
            sl.SliceNumbers(1) = idx;
    end
  
    % Use getframe to capture image.
    I = getframe(Axes);
    [indI,cm] = rgb2ind(I.cdata,256);
  
    % Write frame to the GIF File.
    if idx == 1
        imwrite(indI,cm,filename,'gif','Loopcount',inf,'DelayTime',0.1);
    else
        imwrite(indI,cm,filename,'gif','WriteMode','append','DelayTime',0.1);
    end
end
end

