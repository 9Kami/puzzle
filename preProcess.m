function puzzlePiece = preProcess(number, filename)
    exceptions = [14, 15, 62, 101];
    I=imread(filename);
    I=rgb2gray(I);
    RECT = [1300,500,1500,1500];
    I=imcrop(I,RECT);
    I= medfilt2(I);
    %figure;imshow(I);title('I');

    BW = ~imbinarize(I, graythresh(I));
    BW = bwareaopen(BW,100);
    BW = imfill(BW, 'holes');
    %figure;imshow(BW);title('BW');

    edge = boundarymask(BW);
    %figure;imshow(edge);title('edge');

    [pointc, pointr] = find(edge);
    %[posr, posc] = HarrisPoints(edge,0.1);
    %points = detectMinEigenFeatures(edge,'MinQuality',0.6);
    %pointr = round(points.Location(:,1));
    %pointc = round(points.Location(:,2));

    %figure
    %imshow(edge);
    %hold on;
    %plot(pointr,pointc,'w*');

    %Get vertices
    upperLeft = getVertex(pointr,pointc);
    upperRight = getVertex(pointr*(-1),pointc);
    lowerLeft = getVertex(pointr,pointc*(-1));
    lowerRight = getVertex(pointr*(-1),pointc*(-1));
    
    if ismember(number, exceptions)
        imshow(edge);
        title('Please point out the vertices of this puzzle piece clockwise starting from the upper left, and then press enter.');
        [row,col] = getpts();
        upperLeft = getVertexFromSelections(pointr,pointc,row(1),col(1));
        upperRight = getVertexFromSelections(pointr,pointc,row(2),col(2));
        lowerRight = getVertexFromSelections(pointr,pointc,row(3),col(3));
        lowerLeft = getVertexFromSelections(pointr,pointc,row(4),col(4));
        close;
    end

    %Get the two diagonals
    diagonalTLToBR = getLineEquation(upperLeft,lowerRight);
    diagonalBLToTR = getLineEquation(lowerLeft,upperRight);

    if 0
    figure
    imshow(edge);
    hold on;
    plot(upperLeft(1),upperLeft(2),'*');
    plot(upperRight(1),upperRight(2),'*');
    plot(lowerLeft(1),lowerLeft(2),'*');
    plot(lowerRight(1),lowerRight(2),'*');
    title(['puzzle piece ',num2str(number)]);
    end

    %initilaze binary images of the 4 edges
    leftEdgeIm = false(size(edge,1),size(edge,2));
    topEdgeIm = false(size(edge,1),size(edge,2));
    rightEdgeIm = false(size(edge,1),size(edge,2));
    bottomEdgeIm = false(size(edge,1),size(edge,2));

    %divide edge into 4 edges
    for i = 1:size(edge,1)
        for j = 1:size(edge,2)
            y1 = getY(i,diagonalTLToBR);
            y2 = getY(i,diagonalBLToTR);
            if y1 <= y2
                if j <= y1
                    leftEdgeIm(i,j) = edge(i,j);
                elseif j <= y2
                    topEdgeIm(i,j) = edge(i,j);
                else
                    rightEdgeIm(i,j) = edge(i,j);
                end
            else
                if j < y2 
                    leftEdgeIm(i,j) = edge(i,j);
                elseif j <= y1
                    bottomEdgeIm(i,j) = edge(i,j);
                else
                    rightEdgeIm(i,j) = edge(i,j);
                end
            end
        end
    end

    top = Edge(topEdgeIm,getEdgeType(topEdgeIm, 0),[upperLeft; upperRight]);
    right = Edge(rightEdgeIm,getEdgeType(rightEdgeIm, 1),[upperRight; lowerRight]);
    bottom = Edge(bottomEdgeIm,getEdgeType(bottomEdgeIm, 2),[lowerRight; lowerLeft]);
    left = Edge(leftEdgeIm,getEdgeType(leftEdgeIm, 3),[lowerLeft; upperLeft]);

    puzzlePiece = PuzzlePiece(number,edge,[top,right,bottom,left]);
end


function edgeType = getEdgeType(edge, direction)
    angle = direction * 90;
    edge = imrotate(edge,angle);
    %figure
    %imshow(edge);
    [y,x] = find(edge);
    z=polyfit(x,y,2);
    if abs(z(1)) < 0.001
        edgeType = 0;
    elseif z(1) > 0
        edgeType = 1;
    else
        edgeType = -1;
    end    
end

function vertex = getVertex(row,col)
    min = row(1) + col(1);
    vertex = [row(1), col(1)];

    for i = 2:size(row,1)
        sum = row(i) + col(i);
        if sum < min
            vertex = [abs(row(i)), abs(col(i))];
            min = sum;
        end
    end
end

function lineEquation = getLineEquation(point1,point2)
k = (point1(1) - point2(1)) / (point1(2) - point2(2));
b = point1(1);
lineEquation = [k,b,point1(2)];
end

function y = getY(x,lineEquation)
y = lineEquation(1) * (x - lineEquation(3)) + lineEquation(2);
end

function vertex = getVertexFromSelections(row,col,selectedr,selectedc)
	min = abs(row(1)-selectedr) + abs(col(1)-selectedc);
	for i = 2:size(row,1)
            sum = abs(row(i)-selectedr) + abs(col(i)-selectedc);
            if sum < min
                vertex = [row(i), col(i)];
                min = sum;
            end
	end
end
