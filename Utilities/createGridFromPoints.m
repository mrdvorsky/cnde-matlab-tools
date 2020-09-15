function [ Xg, Yg ] = createGridFromPoints(Xp, Yp, size1, size2)

xOuter1 = linspace(Xp(1), Xp(3), size2);
xOuter2 = linspace(Xp(2), Xp(4), size2);
yOuter1 = linspace(Yp(1), Yp(3), size2);
yOuter2 = linspace(Yp(2), Yp(4), size2);

Xg = zeros(size1, size2);
Yg = zeros(size1, size2);
for ii = 1:size(Xg, 2)
    Xg(:, ii) = linspace(xOuter1(ii), xOuter2(ii), size1);
    Yg(:, ii) = linspace(yOuter1(ii), yOuter2(ii), size1);
end

end

