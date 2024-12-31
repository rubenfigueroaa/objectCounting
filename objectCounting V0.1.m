% Overlapping object detection with Distance Transform and Watershed
clear;
close all;
clc;

% Read the target image
img = imread('coins.jpg');

% View the image
figure,
imshow(img);
title('Original Image');

% Convert to Grayscale
img_gray = rgb2gray(img);
figure,
imshow(img_gray);
title('Grayscale Image');

% Apply Gaussian smoothing
img_smooth = imgaussfilt(img_gray, 2.5);

% Convert to Binary Image
BW = imbinarize(img_smooth);
figure,
imshow(BW);
title('Binary Image');

% Complement the image
BW_complement = imcomplement(BW);
figure,
imshow(BW_complement);
title('Complemented Binary Image');

% Fill holes
BW_filled = imfill(BW_complement, 'holes');
figure,
imshow(BW_filled);
title('Filled Binary Image');
%-------------NEW CODE----------------------------
% Distance Transform
D = -bwdist(~BW_filled);
figure,
imshow(D, []);
title('Distance Transform');

% Marker-based Watershed Segmentation
% Create markers using regional maxima
mask = imextendedmin(D, 2); % Adjust sensitivity
figure,
imshowpair(BW_filled, mask, 'montage');
title('Markers for Watershed');

% Modify the distance transform for watershed
D_mod = imimposemin(D, mask);

% Perform watershed segmentation
L = watershed(D_mod);

% Create segmented binary mask
BW_seg = BW_filled;
BW_seg(L == 0) = 0; % Set watershed lines to 0
figure,
imshow(BW_seg);
title('Watershed Segmentation');

%-------------FINISH OF NEW UPDATE

% Remove small objects (noise) using bwareaopen
threshold = 2500; % Adjust as needed
BW_final = bwareaopen(BW_seg, threshold);

% Count the number of separated objects
objects = bwconncomp(BW_final);
numberObjects = objects.NumObjects;

disp('The total number of objects are : ');
disp(numberObjects);

% Display the final segmented image
imshow(BW_final);
title('Final Segmentation After Area Filtering');

% Add text annotation to display the total number of coins
textPosition = [10, 10]; % Adjust position (x, y) based on your image
textString = sprintf('Total Objects: %d', numberObjects);
textColor = 'red'; % Change color as needed
text(textPosition(1), textPosition(2), textString, 'Color', textColor, 'FontSize', 12, 'FontWeight', 'bold');