function [ angles, magnitudes ] = computeGradient( im )
%COMPUTEGRADIENT Given an image, computes the pixel gradients
% Arguments:
%          im - an image matrix read in by im2read (size H X W X C)
%
% Returns:
%          angles - (H-2) x (W-2) matrix of gradient angles
%          magnitudes - (H-2) x (W-2) matrix of gradient magnitudes
%
% The way that the angles and magnitude per pixel are computed as follows:
% Given the following pixel grid
%
%    P1 P2 P3
%    P4 P5 P6
%    P7 P8 P9
% 
% We compute the angle on P5 as arctan(P4-P6 / P2-P8). 
% The magnitude on P5 is sqrt((P2-P8)^2 + (P4-P6)^2)
%
% On multiple color channels, we simply take the max of each difference 
%(i.e max of each of the P2-P8 or P4-P6 RGB differences). 

% TODO: FILL IN THIS FUNCTION
angles = [];
magnitudes = [];
[H, W, C] = size(im);
for i = 2:H-1
    for j = 2:W-1
        p2 = reshape(im(i-1, j, :),1,[],1);
        p8 = reshape(im(i+1, j, :),1,[],1);
        p4 = reshape(im(i, j-1, :),1,[],1);
        p6 = reshape(im(i, j+1, :),1,[],1);
        angle = atand(max(p4-p6) / max(p2-p8)) + 90;
        magnitude = sqrt(max(p2-p8).^2 + (max(p4-p6)).^2);
        if isnan(angle)
            angles(i-1,j-1) = 0;
        else
            angles(i-1, j-1) = angle;
        end
        magnitudes(i-1,j-1) = magnitude;
    end
end
end

