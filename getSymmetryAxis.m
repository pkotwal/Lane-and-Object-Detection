function [found, axis, symmetryImage, lowestI, highestI, lowestJ, highestJ ] = getSymmetryAxis(image, hStart, hEnd, wStart, wEnd)
upperThresh = 150;
lowerThresh = 20;
acc = zeros( wEnd, 1);
[n, m] = size(image);
symmetryImage = zeros(n, m);

% for i=hStart:hEnd
%         modifiedUpperThresh = round(upperThresh + (((i - hEnd) * 2 * upperThresh) / (3 * (hEnd - hStart)) ));
%     modifiedLowerThresh = round(2 * lowerThresh + ((lowerThresh * (i - hEnd)) / (hEnd - hStart) ));
%     display([i, modifiedUpperThresh]);
% end


for i=hStart:hEnd
        modifiedUpperThresh = round(upperThresh + (((i - hEnd) * 2 * upperThresh) / (3 * (hEnd - hStart)) ));
    modifiedLowerThresh = round(2 * lowerThresh + ((lowerThresh * (i - hEnd)) / (hEnd - hStart) ));
    for j=wStart:wEnd
        
        if(image(i, j) == 255)
            for k=j+1:wEnd
                if(image(i, k) == 255)
                    dist =  k - j;
                    if(dist > modifiedLowerThresh && dist < modifiedUpperThresh)
                        axis = round((j+k)/2);
                        acc(axis) = acc(axis) + 1;
                    end
                end
            end
        end
    end
end
[found, axis] = max(acc);
lowestI = hEnd;
highestI = 0;

lowestJ = axis - lowerThresh;
highestJ = 0;

for i=hStart:hEnd
            modifiedUpperThresh = round(upperThresh + (((i - hEnd) * 2 * upperThresh) / (3 * (hEnd - hStart)) ));
    modifiedLowerThresh = round(2 * lowerThresh + ((lowerThresh * (i - hEnd)) / (hEnd - hStart) ));
    for j=axis-modifiedUpperThresh:axis - modifiedLowerThresh
        if(j>0 && (2*axis - j+ 1)<= wEnd && image(i, j) == 255 && (image(i, 2*axis - j)==255 || image(i, 2*axis - j - 1)==255 || image(i, 2*axis - j + 1)==255))
            symmetryImage(i, j) = 255;
            symmetryImage(i, 2*axis - j) = 255;
            if(i < lowestI)
                lowestI = i;
            end
            if(i > highestI)
                highestI = i;
            end
            if(j < lowestJ)
                lowestJ = j;
            end
            if(2*axis - j > highestJ)
                highestJ = 2*axis - j;
            end
%             display([i, j]);
        end
    end
end

end