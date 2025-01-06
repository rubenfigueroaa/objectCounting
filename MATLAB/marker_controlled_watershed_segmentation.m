%Marker Controlled Watershed Segmentation
%Image Processing Toolbox Example

% Step 1. Read Image and Convert it to Grayscale
rgb = imread("pears.png");
I = im2gray(rgb);
imshow(I)

% Step 2. Use Gradient Magnitude as Segmentation Function
%Gradient Magnitude measures how strong is the change in image intensity
gmag = imgradient(I);
imshow(gmag,[])
title("Gradient Magnitude")

% Step 3. Mark Foreground Objects

%Opening technique
se = strel("disk",20);
Io = imopen(I,se);
imshow(Io)
title("Opening")

%Opening-by-reconstruction technique
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
imshow(Iobr)
title("Opening-by-reconstruction")

%Opening and closing technique
Ioc = imclose(Io,se);
imshow(Ioc)
title("Opening-Closing")

%imdilate and imreconstruct function with reconstruction
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
imshow(Iobrcbr)
title("Opening-Closing by Reconstruction")

%Calculate regional maxima of Iobrcbr for foreground markers
fgm = imregionalmax(Iobrcbr);
imshow(fgm)
title("Regional Maxima of Opening-Closing by Reconstruction")

%Result interpretaron with superposition with original image
I2 = labeloverlay(I,fgm);
imshow(I2)
title("Regional Maxima Superimposed on Original Image")

%Closing and erosion for edge cleaning and marker blobs shrink
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

%bwareaopen to remove small places of pixels
fgm4 = bwareaopen(fgm3,20);
I3 = labeloverlay(I,fgm4);
imshow(I3)
title("Modified Regional Maxima Superimposed on Original Image")

%Step 4. Compute Background Markers
bw = imbinarize(Iobrcbr);
imshow(bw)
title("Thresholded Opening-Closing by Reconstruction")

%Watershed transfrom to ridge lines and segmentation
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
imshow(bgm)
title("Watershed Ridge Lines")

% Step 5. Compute Watershed Transform of Segmentation Function
gmag2 = imimposemin(gmag,bgm | fgm4);
L = watershed(gmag2);

%Step 6. Result Visualization with SuperImpose of all techniques for better
%Segmentation of Foreground and Background Markers
labels = imdilate(L==0,ones(3,3)) + 2*bgm + 3*fgm4;
I4 = labeloverlay(I,labels);
imshow(I4)
title("Markers and Object Boundaries Superimposed on Original Image")

%Visualization image as color image
Lrgb = label2rgb(L,"jet","w","shuffle");
imshow(Lrgb)
title("Colored Watershed Label Matrix")

%Transparency to superimpose the color matrix on top of original intensity
%image
figure
imshow(I)
hold on
himage = imshow(Lrgb);
himage.AlphaData = 0.3;
title("Colored Labels Superimposed Transparently on Original Image")
