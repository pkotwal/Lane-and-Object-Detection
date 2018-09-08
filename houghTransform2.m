function hough = houghTransform(image, lTheta, rTheta)
    [m, n, ~] = size(image);
    diagonal = sqrt(m^2 + n^2);
    hough = zeros( round(diagonal/2), 360);
    for i = round(m/2):m
        for j = 100:n-100
            if(image(i,j) == 255)
                for theta = [lTheta rTheta]
                    r = round(j*cosd(theta) + i*sind(theta));
                    if(r>1 && r<size(hough, 1))
                        hough(r, theta) = hough(r, theta)+1;
                    end
                end     
            end
        end
    end
end