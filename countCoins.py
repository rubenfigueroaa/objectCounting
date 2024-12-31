import cv2
import numpy as np
from scipy.ndimage import distance_transform_edt
from skimage.feature import peak_local_max
from scipy import ndimage as ndi
from skimage.segmentation import watershed

# Read the target image
img = cv2.imread('coins.jpg')
cv2.imshow("Original Image", img)
cv2.waitKey(0)

# Convert to grayscale
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imshow('Grayscale Image', img_gray)
cv2.waitKey(0)

# Apply Gaussian smoothing
img_smooth = cv2.GaussianBlur(img_gray, (5, 5), 2.5)

# Convert to binary image using Otsu thresholding
_, BW = cv2.threshold(img_smooth, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
cv2.imshow('Binary Image', BW)
cv2.waitKey(0)

# Complement the image
BW_complement = cv2.bitwise_not(BW)
cv2.imshow('Complemented Binary Image', BW_complement)
cv2.waitKey(0)

# Fill holes in the complement image
BW_filled = ndi.binary_fill_holes(BW_complement).astype(np.uint8) * 255
cv2.imshow('Filled Binary Image', BW_filled)
cv2.waitKey(0)

# Distance Transform
D = distance_transform_edt(BW_filled)
cv2.imshow('Distance Transform', (D / D.max() * 255).astype(np.uint8))
cv2.waitKey(0)

# Marker-based Watershed Segmentation
# Create markers using regional maxima (peaks)
peaks = peak_local_max(D, labels=BW_filled, footprint=np.ones((3, 3)), num_peaks_per_label=1)

# Debugging: Check the detected peaks
print(f"Number of peaks detected: {len(peaks)}")
print(f"First few peak coordinates: {peaks[:5]}")

# Create markers array, initialize with zeros, then set the peaks to a unique value
markers = np.zeros_like(BW_filled, dtype=np.int32)

# Assign marker values to the peaks
for i, peak in enumerate(peaks):
    markers[peak[0], peak[1]] = i + 1  # Each peak gets a unique marker value

# Debugging: Check the markers image
cv2.imshow('Markers Image', markers.astype(np.uint8) * 40)  # Display markers scaled for visibility
cv2.waitKey(0)

# Modify the distance transform for watershed
D_neg = -D  # Negative distance for watershed

# Perform watershed segmentation
segmentation = watershed(D_neg, markers, mask=BW_filled)

# Debugging: Check segmentation results
cv2.imshow('Segmentation Result', segmentation.astype(np.uint8) * 40)  # Highlight regions
cv2.waitKey(0)

# Create segmented binary mask
BW_seg = np.zeros_like(BW_filled, dtype=np.uint8)
BW_seg[segmentation > 0] = 255

cv2.imshow('Watershed Segmentation', BW_seg)
cv2.waitKey(0)

cv2.destroyAllWindows()

# Remove small objects (noise) using connected components
threshold = 2500  # Threshold for object area size
num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(BW_seg, connectivity=8)

# Initialize the final output binary image
BW_final = np.zeros_like(BW_seg)

# Filter objects based on area size
for i in range(1, num_labels):  # Skip the background label 0
    if stats[i, cv2.CC_STAT_AREA] > threshold:
        BW_final[labels == i] = 255

# Count the number of separated objects
num_objects = np.sum([1 for i in range(1, num_labels) if stats[i, cv2.CC_STAT_AREA] > threshold])
print(f'The total number of objects are: {num_objects}')

# Display the final segmented image after area filtering
cv2.imshow('Final Segmentation After Area Filtering', BW_final)
cv2.waitKey(0)

# Add text annotation to display the total number of objects
font = cv2.FONT_HERSHEY_SIMPLEX
position = (10, 30)
font_scale = 1
font_color = (0, 0, 255)  # Red color
thickness = 2
text = f'Total Objects: {num_objects}'
cv2.putText(img, text, position, font, font_scale, font_color, thickness)
cv2.imshow('Final Output with Annotations', img)
cv2.waitKey(0)

cv2.destroyAllWindows()
