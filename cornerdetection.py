
import cv2
import numpy as np
from scipy.io import savemat

# image names -> puzzle_1.JPG
inputDir = './inputimage/'
outputDir = './outputimage/'

# dictionary to store corners coordinates
cornersCordinate = {}

# loop through all 108 images
for i in range(108):
    # format of the filename
    filename = "puzzle_" + str(i + 1) + ".JPG"

    # read the image
    img = cv2.imread(inputDir + filename)

    # apply gaussian filter
    img = cv2.GaussianBlur(img, (5, 5), 0)
    
    # apply median filter
    img = cv2.medianBlur(img, 7)

    # Shi-Tomasi corner detection
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # detected corners
    corners = cv2.goodFeaturesToTrack(gray, 4, 0.2, 250)

    corners = np.int0(corners)
    
    # storing in dictionary
    cornersCordinate["puzzlePiece_"+str(i+1)] = np.array(corners)

    # draw red color circles on all corners
    for i in corners:
        x, y = i.ravel()
        cv2.circle(img, (x, y), 3, (0, 0, 255), -1)

    # save the image showing corners
    cv2.imwrite(outputDir + filename, img)

# save corners in the mat file
savemat("test.mat", cornersCordinate)
print("Done")
cv2.waitKey(0)
