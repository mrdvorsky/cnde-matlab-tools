function viewVolume(Data,ViewType)
color = "jet"
switch (ViewType)
    case "linear"
        volumeViewer(abs(Data))
    case "log"
        volumeViewer(db(abs(Data)))
    case "angle"
        volumeViewer(angle(Data))
    case "real"
        volumeViewer(real(Data))
    case "imag"
        volumeViewer(imag(Data))
end
end