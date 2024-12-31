import cv2
import cvzone
import numpy as np

# Camera connection and size visualization
cap = cv2.VideoCapture(1)
cap.set(3, 640)
cap.set(4, 480)

def empty(a):
    pass

# Threshold and minArea slider
cv2.namedWindow("Settings")
cv2.resizeWindow("Settings", 640, 240)
cv2.createTrackbar("Threshold1", "Settings", 31, 255, empty)
cv2.createTrackbar("Threshold2", "Settings", 35, 255, empty)
cv2.createTrackbar("MinArea", "Settings", 37, 500, empty)  # MinArea slider

def preProcessing(img):
    imgPre = cv2.GaussianBlur(img, (5, 5), 3)
    thresh1 = cv2.getTrackbarPos("Threshold1", "Settings")
    thresh2 = cv2.getTrackbarPos("Threshold2", "Settings")
    imgPre = cv2.Canny(imgPre, thresh1, thresh2)
    kernel = np.ones((2, 2), np.uint8)  # dilation for bigger contours
    imgPre = cv2.dilate(imgPre, kernel, iterations=1)
    imgPre = cv2.morphologyEx(imgPre, cv2.MORPH_CLOSE, kernel)
    return imgPre

while True:
    success, img = cap.read()
    if not success:
        break

    imgPre = preProcessing(img)

    # Get the minArea value from the trackbar
    minArea = cv2.getTrackbarPos("MinArea", "Settings")

    # Find contours and filter by minArea
    imgContours, conFound = cvzone.findContours(img, imgPre, minArea=minArea)

    # Number of coins detected
    coinCount = len(conFound)

    # Stack images for visualization
    imgStacked = cvzone.stackImages([img, imgPre, imgContours], 2, 0.75)

    # Display the coin count on the stacked image
    cv2.putText(imgStacked, f"Coins Detected: {coinCount}", (20, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

    # Show the result
    cv2.imshow("Image", imgStacked)
    if cv2.waitKey(1) & 0xFF == ord('q'):  # Press 'q' to exit the loop
        break

cap.release()
cv2.destroyAllWindows()
