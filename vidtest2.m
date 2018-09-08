clc;

v = VideoReader('lane2.mp4');
figure('Name', 'Output');

v.CurrentTime = 680;
fcounter = 0;
lineFound = 0;
vidWidth = v.Width;
vidHeight = v.Height;
vidHalfHeight = round(vidHeight/2);
lfound =0;
rfound = 0;

while hasFrame(v)
    if lfound == 0
        lTheta = 30 : 90;
    end
    
    if rfound == 0
        rTheta = 270:330;
    end
    
    I = readFrame(v);
    image = rgb2gray(I);
    
    diffFrameGreen = imsubtract(I(:,:,2), image);
    diffFrameGreen = medfilt2(diffFrameGreen, [3 3]);
    binFrameGreen = im2bw(diffFrameGreen, 0.075);
    binFrameGreen(1:100, :) = 0;
    
    s = regionprops(binFrameGreen,'BoundingBox');
    boundingBoxes = cat(1, s.BoundingBox);
    
    heightStart = vidHalfHeight + 30;
    heightEnd = vidHeight;
    widthStart = 50;
    widthEnd = vidWidth-200;
    
    image(heightStart:heightEnd, widthStart:widthEnd) = imgaussfilt(image(heightStart:heightEnd, widthStart:widthEnd),2);
    
    edges = image;
    edges(heightStart:heightEnd, widthStart:widthEnd) = double(edge(image(heightStart:heightEnd, widthStart:widthEnd), 'sobel')) .* 255;
    
    
    hough = houghTransform2(edges, 45 : 75, 285:315 );
    [axisFound, axis, symmetryImage, lowestI, highestI, lowestJ, highestJ ] = getSymmetryAxis(edges, heightStart, heightEnd, widthStart, widthEnd);
    
    [M, r] = max(hough);
    [N, theta] = max(M);
    
    lowestM = 100;
    highestM = 0;
    LeftX = [];
    RightX = [];
    found = 0;
    
    Y = size(I, 1)-250 : size(I, 1);
    count = 0;
    found = 0;
    rfound = 0;
    lfound = 0;
    
    while N>75
        m = -(cosd(theta))/sind(theta);
        b = r(theta)/sind(theta);
        
        if(abs(m)>0.7 && abs(m) < 1.73)
            
            count = count + 1;
            X = (Y - b) ./ m;
            
            if(m<0)
                if(m<lowestM)
                    lowestM = m;
                    rfound = 1;
                    RightX = X;
                    lineFound = 1;
                    rTheta = theta-5:theta+5;
                    oldRX =RightX;
                end
            end
            if(m>0)
                if(m>highestM)
                    highestM = m;
                    lfound = 1;
                    LeftX = X;
                    lineFound = 1;
                    lTheta =theta-5:theta+5;
                    oldLX= LeftX;
                    
                end
            end
            
            if lfound == 1 && rfound == 1
                found = 1;
            end
        end
        %     Erase discovered point and look for next brightest point
        if(r(theta)>5 && theta>5)
            region = 5;
        else
            region = min(r(theta), theta) - 1;
        end
        hough(r(theta)-region : r(theta)+region, theta-region:theta+region) = 0;
        [M, r] = max(hough);
        [N, theta] = max(M);
    end
    
    if lineFound == 1
        
        
        
        leftLaneMarker = round(oldLX(length(oldLX)));
        rightLaneMarker = round(oldRX(length(oldRX)));
        
        centerOfImage = round(vidWidth / 2);
        centerOfvehicle = round(( leftLaneMarker + rightLaneMarker ) / 2);
        laneWidth = leftLaneMarker - rightLaneMarker;
        
        offset = centerOfImage - centerOfvehicle;
        offsetInInches = (12 * offset / laneWidth) * 12;
        
        if(offset > 0)
            direction = 'Right';
        else
            direction = 'Left';
        end
                text_str = cell(1,1);

                if(offset == 0)
                            text_str{1} = ['Vehicle Centered'];
                else
                           text_str{1} = ['You are ' num2str(abs(offsetInInches),'%0.2f') ' inches to the ' direction];
                end

                       % I = insertText(I, [round(vidWidth/2), 30], text_str, 'FontSize', 24, 'BoxColor', 'red', 'BoxOpacity', 0.0, 'AnchorPoint', 'Center');
        
%         imshow(binFrameGreen, [0, 1]);
imshow(I);
        hold on;
        
        if( axisFound > 58)
            if(highestJ-lowestJ + 10 > 0)
                width = highestJ-lowestJ + 10;
            else
                width = 0;
            end
            
            if(highestI-lowestI + 10 > 0)
                height = highestI-lowestI + 10;
            else
                height = 0;
            end
            rectangle('Position',[lowestJ - 10, lowestI - 10, width, height],  'LineWidth',2, 'EdgeColor', 'r');
        end
        
        for i=1:size(boundingBoxes, 1)
            rectangle('Position',boundingBoxes(i, :),  'LineWidth',2, 'EdgeColor', 'g');
        end
        
        BetweenX = [oldLX, fliplr(oldRX)];
        BetweenY = [Y, fliplr(Y)];
        h = fill(BetweenX, BetweenY, 'b');
        set(h,'facealpha',.3);
        
        drawnow;
        

        
    else
        display("POPO");
    end
    
    hold off;
    %     toc;
end