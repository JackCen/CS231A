Funcfunction extractHoGFeature(imgNum, inFile, outFile, offset)
cell_size = 6;
block_size = 2;
nbins = 9;
window_size = [19 19];

total_block_size = block_size*cell_size;
template_size = (floor((window_size(1)-2)/(total_block_size/2)) - 1) * (floor((window_size(2)-2)/(total_block_size/2)) - 1);
D = template_size * block_size * block_size * nbins;
features = zeros(imgNum, D);
for i = 1:imgNum
    imageName = sprintf('%s%04d.pgm', inFile, offset+i);
    image = imread(imageName);  
    image = double(image);
    features(i,:) = reshape(computeHOGFeatures(image, cell_size, block_size, nbins), 1, D);

    if mod(i,50) == 0
        fprintf(' %d', i);
    end
end

save(outFile, 'features', '-mat', '-v7.3');



  