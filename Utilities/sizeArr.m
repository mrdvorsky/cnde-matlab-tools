function [ dimSizes ] = sizeArr( A, dims )

dimSizes = zeros(size(dims));
for ii = 1:length(dims(:))
    dimSizes(ii) = size(A, dims(ii));
end

end

