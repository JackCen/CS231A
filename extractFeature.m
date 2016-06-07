
function features = extractFeature(imgNum, inFile, outFile, offset)

T = zeros(19,1);
subWindow = zeros(20,20);
features = zeros(34200, imgNum);

% >>> display the progress <<< %
fprintf('images processed = ');

for k = 1:imgNum
    
    imageName = sprintf('%s%05d.pgm', inFile, offset+k);
    image = imread(imageName);
    %image = rgb2gray(image);
    
    %>>> compute the image integral <<<%
    
    for i = 2:20
        for j = 2:20
            T(1:i-1) = sum(image(1:i-1, 1:j-1), 2);
            subWindow(i,j) = sum(T(1:i-1), 1);
        end
    end
    
    %>>> extract the vertical Haar-like features <<<%
    
    count = 0;
    for h = 1:19
        for w = 1:9
            for i = 1:20-h
                for j = 1:20-2*w
                    x1 = j;
                    x2 = j;
                    x3 = j + w;
                    x4 = j + w;
                    x5 = j + 2 * w;
                    x6 = j + 2 * w;
                    y1 = i;
                    y2 = i + h;
                    y3 = i;
                    y4 = i + h;
                    y5 = i;
                    y6 = i + h;
                    
                    count = count + 1;
                    features(count, k) = -subWindow(y1,x1) + ...
                        subWindow(y2,x2) + 2 * subWindow(y3,x3) - ...
                        2 * subWindow(y4,x4) - subWindow(y5,x5) + subWindow(y6,x6);
                end
            end
        end
    end
    
    %>>> extract the horizontal Haar-like features <<<%
    
    for h = 1:9
        for w = 1:19
            for i = 1:20-2*h
                for j = 1:20-w
                    x1 = j;
                    x2 = j + w;
                    x3 = j;
                    x4 = j + w;
                    x5 = j;
                    x6 = j + w;
                    y1 = i;
                    y2 = i;
                    y3 = i + h;
                    y4 = i + h;
                    y5 = i + 2 * h;
                    y6 = i + 2 * h;
                    
                    count = count + 1;
                    features(count, k) = -subWindow(y1,x1) + ...
                        subWindow(y2,x2) + 2 * subWindow(y3,x3) - ...
                        2 * subWindow(y4,x4) - subWindow(y5,x5) + subWindow(y6,x6);
                end
            end
        end
    end

% >>> display the progress <<< %
if mod(k,50) == 0
    fprintf(' %d', k);
end


% >>> save features to MAT file <<< %
save(outFile, 'features', '-mat', '-v7.3');

end
                    

