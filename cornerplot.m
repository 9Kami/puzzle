
for i = 1:108
%   file names are in the form: puzzle_1.JPG;
    imgLocation = './inputimage/';
    filename = ['puzzle_',num2str(i),'.JPG'];
    file = [imgLocation, filename]; 
%   disp(file);

%   read the image file
    I = imread(file);
    
%   get corners from the mat file
    corners = load("corners.mat");

%   c = corners.puzzlePiece_1;
    c = corners.(['puzzlePiece_',num2str(i)]);
%   separate x and y coordinates of the corners point
    x = c(:,:,1);
    y = c(:,:,2);
    
    imshow(I);

    hold on;
    plot(x, y, 'r*', 'MarkerSize', 10);
    F = getframe;
%   save the file by plotting corners over the image
    imwrite(F.cdata, ['./cornerplottedimage/', filename]);
    
     hold off;

end
