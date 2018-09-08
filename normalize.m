function [newImage] = normalize(image)
   
    minimum = (min(min(image)));
    maximum = (max(max(image)));
    newImage = 255 * double((image - minimum)) ./ double(maximum - minimum);
    
end