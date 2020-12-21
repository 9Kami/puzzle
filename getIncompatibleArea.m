function filledArea = getIncompatibleArea(edge1, edge2, edge1Num, edge2Num)
    %Rotate the two edges so that one faces right and one faces left
    edge1rotation = mod((2-edge1Num) * 90,360);
    edge2rotation = mod((4-edge2Num) * 90,360);
    [edge1Im, endpoint1A, endpoint1B] = edgeRotate(edge1,edge1rotation);
    [edge2Im, endpoint2A, endpoint2B] = edgeRotate(edge2,edge2rotation);

    [edge1y,edge1x] = find(edge1Im);
    [edge2y,edge2x] = find(edge2Im);
    
    %Get the endpoint indexes of edge2 so that the endpoint coordinates can still be found after the edge is translated and rotated
    min1 = intmax('int8');
    min2 = intmax('int8');
    for i = 1:size(edge2y)
        distanse1 = abs(edge2x(i)-endpoint2A(1)) + abs(edge2y(i)-endpoint2A(2));
        if distanse1 < min1
            min1 = distanse1;
            endpoint2AIndex = i;
        end
        distanse2 = abs(edge2x(i)-endpoint2B(1)) + abs(edge2y(i)-endpoint2B(2));
        if abs(edge2x(i)-endpoint2B(1)) + abs(edge2y(i)-endpoint2B(2)) < min2
            min2 = distanse2;
            endpoint2BIndex = i;
        end
    end

    %Shift edge2 so that one end of the two edges coincide
    for i = 1:size(edge2y)
        edge2y(i) = edge2y(i)- (endpoint2B(2)-endpoint1A(2));
    end

    for i = 1:size(edge2x)
        edge2x(i) = edge2x(i)- (endpoint2B(1)-endpoint1A(1));
    end

    %figure
    %imshow(edge1Im);
    %hold on
    %plot(edge2x,edge2y,'*');

    %Rotate edge2 according to the slope of edge1 so that the two edges roughly coincide
    slope1 = (endpoint1B(1)-endpoint1A(1))/(endpoint1B(2)-endpoint1A(2));
    radian1 = atan(slope1);


    slope2 = (endpoint2A(1)-endpoint2B(1))/(endpoint2A(2)-endpoint2B(2));
    radian2 = atan(slope2);

    rotatedAngle = radian2-radian1;

    for i = 1:size(edge2y)
        edge2y(i)= (edge2x(i) - endpoint1A(1))*sin(rotatedAngle) + (edge2y(i) - endpoint1A(2))*cos(rotatedAngle) + endpoint1A(2);
    end

    for i = 1:size(edge2x)
        edge2x(i)= (edge2x(i) - endpoint1A(1))*cos(rotatedAngle) - (edge2y(i) - endpoint1A(2))*sin(rotatedAngle) + endpoint1A(1);
    end

    %Draw the new two edge points onto a image
    combination = false(size(edge1Im,1),size(edge1Im,2));
    for i = 1:size(edge1y)
        combination(edge1y(i),edge1x(i)) = 1;
    end
    for i = 1:size(edge2y)
        combination(round(edge2y(i)),round(edge2x(i))) = 1;
    end
    
    %Connect the endpoints of the two edges to close possible openings to ensure that imfill() can fill correctly
    newEndpoint2A = [round(edge2x(endpoint2AIndex)),round(edge2y(endpoint2AIndex))];
    newEndpoint2B = [round(edge2x(endpoint2BIndex)),round(edge2y(endpoint2BIndex))];
    
    line1A2B = getLineEquation(endpoint1A,newEndpoint2B);
    line1B2A = getLineEquation(endpoint1B,newEndpoint2A);
    
    for i = min(endpoint1A(2),newEndpoint2B(2)):max(endpoint1A(2),newEndpoint2B(2))
        for j = 1:size(combination,2)
            y = getY(i,line1A2B);
            if j == round(y)
                combination(i,j) = 1;
            end
        end
    end
    
    for i = min(endpoint1B(2),newEndpoint2A(2)):max(endpoint1B(2),newEndpoint2A(2))
        for j = 1:size(combination,2)
            y = getY(i,line1B2A);
            if j == round(y)
                combination(i,j) = 1;
            end
        end
    end

    %Fill the overlap/unfilled area of the two edges and calculate the filled area
    filledCombination = imfill(combination,'holes');
    filledArea = size(find(filledCombination),1) - size(find(combination),1);

    %figure
    %imshow(filledCombination);

    %figure
    %imshow(edge1Im);
    %hold on
    %plot(edge2x,edge2y,'*');
end

function [edgeIm, endpointA, endpointB] = edgeRotate(edge,rotation)
    edgeIm = imrotate(edge.edgeIm,360 - rotation);
    
    switch (rotation)
        case 0
            endpointA = edge.endpoints(1,:);
            endpointB = edge.endpoints(2,:);
        case 90
            endpointA(1) = size(edgeIm,2) - edge.endpoints(1,2);
            endpointA(2) = edge.endpoints(1,1);
            endpointB(1) = size(edgeIm,2) - edge.endpoints(2,2);
            endpointB(2) = edge.endpoints(2,1);
        case 180
            endpointA(1) = size(edgeIm,2) - edge.endpoints(1,1);
            endpointA(2) = size(edgeIm,1) - edge.endpoints(1,2);
            endpointB(1) = size(edgeIm,2) - edge.endpoints(2,1);
            endpointB(2) = size(edgeIm,1) - edge.endpoints(2,2);
        case 270
            endpointA(1) = edge.endpoints(1,2);
            endpointA(2) = size(edgeIm,1) - edge.endpoints(1,1);
            endpointB(1) = edge.endpoints(2,2);
            endpointB(2) = size(edgeIm,1) - edge.endpoints(2,1);
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


