%First iteration
%Image object counting of separated Shapes
clear;
close all;
clc;

%Read the target image

img = imread('threedShapes.png');

%View the image

figure,
imshow(img);

%Convert to Grayscale image

img_gray = rgb2gray(img);
figure,
imshow(img_gray);

% Apply Gaussian smoothing to remove details 
img_smooth = imgaussfilt(img_gray, 2.5);

%Convert to Binary Version of Image

BW = imbinarize(img_smooth);
figure
imshowpair(img_gray,BW, 'montage');

%Complement the image

BW1 = imcomplement(BW);
figure,
imshow(BW1);

%Fill the holes to make a Solid Object 

BW2 = imfill(BW1,'holes');
figure,
imshow(BW2);

%Filter the image through static area open
%BW3= bwareaopen(BW2,2500); %More pixels, starts getting closer

%Dynamic threshold of pixel calculations is necessary plus the gaussian
%smoothing
stats = regionprops(BW2, 'Area');
areas = [stats.Area];
avg_area = mean(areas); % Compute average area of blobs dont count 
%threshold = round(avg_area / 2); % Set threshold dynamically (e.g., half of average)
threshold = 2500;
BW3 = bwareaopen(BW2, threshold);
figure,
imshow(BW3);
%Number of objects

objects = bwconncomp(BW3);
numberObjects = objects.NumObjects;

disp('The total number of objects are : ');
disp(numberObjects );

