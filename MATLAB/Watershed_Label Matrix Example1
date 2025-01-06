%Watershed Documentation and Display Resulting Label Matrix Example
%Create a binary image containing two overlapping circular objects. Display
%the image

center1 = -40;
center2 = -center1;
dist = sqrt(2*(2*center1)^2);
radius = dist/2 * 1.4;
lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
[x,y] = meshgrid(lims(1):lims(2));
bw1 = sqrt((x-center1).^2 + (y-center1).^2) <= radius;
bw2 = sqrt((x-center2).^2 + (y-center2).^2) <= radius;
bw = bw1 | bw2;
imshow(bw)
title('Binary Image with Overlapping Objects')

%Calculate the distance transform, nearest pixels 
D = bwdist(~bw);
imshow(D,[])
title("Distance Transform of the Binary Image")

%Take the compliment (opposites) to indicate light pixels, near the center
%will be the tops, and the darker pixels, will be the valleys or basins, in
%our example we use the distance transform for two simple circles with a
%center

D = -D; 
imshow(D,[])
title('Complement of Distance Transform')

%Apply the watershed transform based on light and dark pixels, mathematical
%label to fill the basins with a binarization of relevant information
L = watershed(D);
L(~bw) = 0;

%Display label matrix as an RGB image
rgb = label2rgb(L,'jet',[.5 .5 .5]);
imshow(rgb)
title('Watershed Transform'
