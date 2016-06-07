function [ features ] = computeHOGFeatures( im, cell_size, block_size, nbins )
%COMPUTEHOGFEATURES Computes the histogram of gradients features
% Arguments:
%          im - the image matrix
%          cell_size - each cell will be of size (cell_size, cell_size)
%                       pixels
%          block_size - each block will be of size (block_size, block_size)
%                       cells
%          nbins - number of histogram bins
% Returns:
%          features - the hog features of the image (H_blocks x W_blocks x cell_size*cell_size*nbins)
%
% Generating the HoG features can be done as follows:
% 1) Compute the gradient for the image
% 2) For a fixed block size (some cell grid), pass a sliding window of this
% block size. Use a 50% overlap. Each cell in each block will store a histogram. 
% Therefore, each block "feature" will contain cell_size x cell_size
% histograms. Make sure to normalize the block feature. The entire HoG
% feature is a concatenation of block features.
% 3) Each cell's histogram will bin the angle from 0 to 180 degrees. The
% number of bins will dictate what angles fall into what bin (i.e. if
% nbins=9, then bin 1 will contain the votes of angles close to 10, bin 2 will contain
% those close to 30, etc). To create these histograms, iterate over the pixels in 
% each cell, putting the gradient into its respective bins. To do this properly, 
% we interpolate and weight the voting for the bins. For example, if we receive 
% angle 20 with magnitude 1, then we vote that it shares equally with bins
% 1 and 2 (since its close to both 10 and 30). If we recieve angle 25 with
% magnitude 2, then it's weighted 25% in bin 0 and 75% in bin 1, but with
% twice the voting power. 
           

 
% TODO: FILL IN THIS FUNCTION
[angles, magnitudes] = computeGradient(im);
height = size(im,1)-2;
width = size(im,2)-2;
totalBlockSize = block_size * cell_size;
slideSize = floor(totalBlockSize / 2);
featureDepth = nbins*block_size*block_size;
featureHeight = floor(height/(totalBlockSize/2))-1;
featureWidth = floor(width/(totalBlockSize/2))-1;
features = zeros(featureHeight, featureWidth, featureDepth);

startH = 1;
for i = 1:featureHeight
    startW = 1;
    for j = 1:featureWidth
        feature = getBlockFeature(startH, startW, cell_size, block_size, nbins, angles, magnitudes);
        for z = 1:featureDepth
            features(i,j,z) = feature(z);
        end
        startW = startW + slideSize;
    end
    startH = startH + slideSize;
end
end

function blockFeature = getBlockFeature(startH, startW, cellSize, blockSize, nbins, angles, magnitudes)
    blockFeature = [];
    for i = startH : cellSize : startH+blockSize*cellSize-1
        for j = startW : cellSize : startW+blockSize*cellSize-1      
            his = getHistogram(i, j, cellSize, nbins, angles, magnitudes);
            blockFeature = cat(2, blockFeature, his);
        end
    end
    if norm(blockFeature) > 0
        blockFeature = blockFeature / norm(blockFeature);
    end
end

function histogram = getHistogram(startH, startW, cellSize, nbins, angles, magnitudes)
    binWidth = 180/nbins;
    histogram = zeros(1,nbins);
    for i = startH:startH+cellSize-1
        for j = startW:startW+cellSize-1
            ang = angles(i, j);
            mag = magnitudes(i, j);
            binIndex1 = floor((ang + (binWidth/2))/binWidth);
            remainder = mod(ang + (binWidth/2), binWidth);
            if remainder == 0
                histogram(1, binIndex1) = histogram(1,binIndex1) + mag;
            else
                if binIndex1 == 0
                    binIndex1 = nbins;
                    binIndex2 = 1;    
                elseif binIndex1 == nbins
                    binIndex2 = 1;
                else
                    binIndex2 = binIndex1 + 1;
                end
                weight2 = remainder / binWidth;
                weight1 = 1 - weight2;
                histogram(1,binIndex1) = histogram(1,binIndex1) + weight1 * mag;
                histogram(1,binIndex2) = histogram(1,binIndex2) + weight2 * mag;    
            end
        end
    end
end





