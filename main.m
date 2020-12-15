n = 108;
m = 108;
distanceSensitivity = 15;
corner0Tab = PuzzlePiece.empty();
corner1Tab = PuzzlePiece.empty();
corner2Tab = PuzzlePiece.empty();
edge0Tab = PuzzlePiece.empty();
edge1TabLeft = PuzzlePiece.empty();
edge1TabRight = PuzzlePiece.empty();
edge1TabDown = PuzzlePiece.empty();
edge2TabRight = PuzzlePiece.empty();
edge2TabLeft = PuzzlePiece.empty();
edge2TabOppsite = PuzzlePiece.empty();
edge3Tab = PuzzlePiece.empty();
internal0Tab = PuzzlePiece.empty();
internal1Tab = PuzzlePiece.empty();
internal2TabOpposite = PuzzlePiece.empty();
internal2TabAdjacent = PuzzlePiece.empty();
internal3Tab = PuzzlePiece.empty();
internal4Tab = PuzzlePiece.empty();
for i = 1:m
    puzzlePiece = preProcess(i,['puzzleIm\puzzle_',num2str(i),'.jpg']);
    switch puzzlePiece.type
        case '0-tab corner piece'
            corner0Tab = [corner0Tab, puzzlePiece];
        case '1-tab corner piece'
            corner1Tab = [corner1Tab, puzzlePiece];
        case '2-tab corner piece'
            corner2Tab = [corner2Tab, puzzlePiece];
        case '0-tab edge piece'
            edge0Tab = [edge0Tab, puzzlePiece];
        case '1-left-tab edge piece'
            edge1TabLeft = [edge1TabLeft, puzzlePiece];
        case '1-right-tab edge piece'
            edge1TabRight = [edge1TabRight, puzzlePiece];
        case '1-down-tab edge piece'
            edge1TabDown = [edge1TabDown, puzzlePiece];
        case '2-right-tab edge piece'
            edge2TabRight = [edge2TabRight, puzzlePiece];
        case '2-left-tab edge piece'
            edge2TabLeft = [edge2TabLeft, puzzlePiece];
        case '2-oppsite-tab edge piece'
            edge2TabOppsite = [edge2TabOppsite, puzzlePiece];
        case '3-tab edge piece'
            edge3Tab = [edge3Tab, puzzlePiece];
        case '0-tab internal piece'
            internal0Tab = [internal0Tab, puzzlePiece];
        case '1-tab internal piece'
            internal1Tab = [internal1Tab, puzzlePiece];
        case '2-opposite-tab internal piece'
            internal2TabOpposite = [internal2TabOpposite, puzzlePiece];
        case '2-adjacent-tab internal piece'
            internal2TabAdjacent = [internal2TabAdjacent, puzzlePiece];
        case '3-tab internal piece'
            internal3Tab = [internal3Tab, puzzlePiece];
        case '4-tab internal piece'
            internal4Tab = [internal4Tab, puzzlePiece];
    end      
end

startPool = [corner0Tab, corner1Tab, corner2Tab];

firstRow = PuzzlePiece.empty();
firstRowNumOnly = zeros();
firstRow(1) = startPool(2);
firstRowNumOnly(1) = firstRow(1).num;
firstRow(1).splicedOn = 1;
for a = 1:4
    if firstRow(1).edges(a).type == 0 && firstRow(1).edges(mod((a-1)-1,4)+1).type == 0
        firstRow(1).afterRotation = [a,mod((a+1)-1,4)+1,mod((a+2)-1,4)+1,mod((a+3)-1,4)+1];
    end
end

meetLast = 0;
i = 2;

while(~meetLast)
    leftNotch = firstRow(i-1).edges(firstRow(i-1).afterRotation(2));
    switch leftNotch.type
        case -1
            searchPool = [edge1TabLeft,edge2TabLeft,edge2TabOppsite,edge3Tab,corner1Tab,corner2Tab];
        case 1
            searchPool = [edge0Tab,edge1TabRight,edge1TabDown,edge2TabRight,corner0Tab,corner1Tab];
    end
    incompatibilities = int16.empty(0,3);
    for a = 1:size(searchPool,2)
        for b = 1:4
            if searchPool(a).edges(b).type + leftNotch.type == 0 && searchPool(a).splicedOn == 0 && abs(searchPool(a).edges(b).endpointsDistance - leftNotch.endpointsDistance) <= distanceSensitivity
                incompatibility = getIncompatibleArea(leftNotch, searchPool(a).edges(b), firstRow(i-1).afterRotation(2), b);
                incompatibilities = [incompatibilities; incompatibility, a, b];
            end
        end
    end
    if isempty(incompatibilities)
        fprintf('Cannot find a puzzle piece for position (1,%d)\n',i);
        fprintf('Currently the frist row of the puzzle is: \n');
        disp(firstRowNumOnly);
        fprintf('\n------------------------------------------------------\n\n');
        return;
    end
    incompatibilities = sortrows(incompatibilities,1);
    firstRow(i) = searchPool(incompatibilities(1,2));
    firstRow(i).afterRotation = [mod((incompatibilities(1,3)+1)-1,4)+1,mod((incompatibilities(1,3)+2)-1,4)+1,mod((incompatibilities(1,3)+3)-1,4)+1,incompatibilities(1,3)];
    firstRow(i).splicedOn = 1;
    meetLast = contains(firstRow(i).type,'corner');
    firstRowNumOnly(i) = searchPool(incompatibilities(1,2)).num;
    i = i+1;
end

fprintf('The frist row of the puzzle is: \n');
disp(firstRowNumOnly);
fprintf('\n------------------------------------------------------\n\n');

puzzle = firstRow;
puzzleNumOnly = firstRowNumOnly;
errorCorrection = 0;

i = 2;
while i <= n/size(firstRow,2)
    j = 1;
    while j <= size(firstRow,2)
        if j == 1
            topNotch = puzzle(i-1,j).edges(puzzle(i-1,j).afterRotation(3));
            switch topNotch.type
                case -1
                    if i == n/size(firstRow,2)
                        searchPool = [corner1Tab, corner2Tab];
                    else
                        searchPool = [edge1TabRight, edge2TabRight, edge2TabOppsite, edge3Tab];
                    end
                case 1
                    if i == n/size(firstRow,2)
                        searchPool = [corner1Tab, corner0Tab];
                    else
                        searchPool = [edge0Tab, edge1TabLeft, edge1TabDown, edge2TabLeft];
                    end
            end
            incompatibilities = int16.empty(0,3);
            for a = 1:size(searchPool,2)
                for b = 1:4
                    if searchPool(a).edges(b).type + topNotch.type == 0 && searchPool(a).edges(mod((b-1)-1,4)+1).type == 0 && searchPool(a).splicedOn == 0 && abs(searchPool(a).edges(b).endpointsDistance - topNotch.endpointsDistance) <= distanceSensitivity
                        incompatibility = getIncompatibleArea(topNotch, searchPool(a).edges(b), puzzle(i-1,j).afterRotation(3), b);
                        incompatibilities = [incompatibilities; incompatibility, a, b];
                    end
                end
            end
            if isempty(incompatibilities)
                fprintf('Cannot find a puzzle piece for position (%d,%d)\n',i,j);
                fprintf('Currently the puzzle is: \n');
                disp(puzzleNumOnly);
                fprintf('Please follow the above to put the puzzle from left to right, from top to bottom, and enter where the error started.\n');
                r = input('Plase enter the row number of the error: ');
                c = input('Plase enter the col number of the error: ');
                fprintf('\nBack to position (%d,%d)...\n', r, c);
                for a = i:-1:r
                    for b = size(firstRow,2):-1:1
                        if a ~= r || b >= c
                            puzzle(a,b).splicedOn = 0;
                            puzzle(a,b).afterRotation = [1,2,3,4];
                            puzzleNumOnly(a,b) = 0;
                        end
                    end
                end
                i = r;
                j = c;
                errorCorrection = 1;
                continue;
            end
            incompatibilities = sortrows(incompatibilities,1);
            candidates = incompatibilities(1,:);
            if errorCorrection
                fprintf('\nError Correction:\n');
                fprintf('Plase selecte a puzzle piece for position (%d,%d)\n',i,j);
                fprintf('The following are the candidate puzzle pieces and their incompatibility: \n');
                for a = 1:size(incompatibilities,1)
                    fprintf('Index: %d | Puzzle pieces: %d | Incompatibility: %d\n',a, searchPool(incompatibilities(a,2)).num, incompatibilities(a,1));
                end
                x = input('enter the index of the puzzle pieces selected: ');
                selected = incompatibilities(x,:);
                errorCorrection = 0;
                fprintf('\n------------------------------------------------------\n\n');
            else
                selected = incompatibilities(1,:);
            end
            puzzle(i,j) = searchPool(selected(2));
            puzzle(i,j).afterRotation = [selected(3),mod((selected(3)+1)-1,4)+1,mod((selected(3)+2)-1,4)+1,mod((selected(3)+3)-1,4)+1];
            puzzle(i,j).splicedOn = 1;
            puzzleNumOnly(i,j) = searchPool(selected(2)).num;
        else
            leftNotch = puzzle(i,j-1).edges(puzzle(i,j-1).afterRotation(2));
            topNotch = puzzle(i-1,j).edges(puzzle(i-1,j).afterRotation(3));
            switch leftNotch.type
                case -1
                    switch topNotch.type
                        case -1
                            if i == n/size(firstRow,2) && j == size(firstRow,2)
                                searchPool = corner2Tab;
                            elseif i == n/size(firstRow,2)
                                searchPool = [edge2TabRight, edge3Tab];
                            elseif j == size(firstRow,2)
                                searchPool = [edge2TabLeft, edge3Tab];
                            else
                                searchPool = [internal2TabAdjacent, internal3Tab, internal4Tab];
                            end
                         case 1
                            if i == n/size(firstRow,2) && j == size(firstRow,2)
                                searchPool = corner1Tab;
                            elseif i == n/size(firstRow,2)
                                searchPool = [edge1TabRight, edge2TabOppsite];
                            elseif j == size(firstRow,2)
                                searchPool = [edge1TabDown, edge2TabRight];
                            else
                                searchPool = [internal1Tab, internal2TabAdjacent, internal2TabOpposite, internal3Tab];
                            end
                    end
                case 1
                    switch topNotch.type
                        case -1
                            if i == n/size(firstRow,2) && j == size(firstRow,2)
                                searchPool = corner1Tab;
                            elseif i == n/size(firstRow,2)
                                searchPool = [edge2TabLeft, edge1TabDown];
                            elseif j == size(firstRow,2)
                                searchPool = [edge1TabLeft, edge2TabOppsite];
                            else
                                searchPool = [internal1Tab, internal2TabAdjacent, internal2TabOpposite, internal3Tab];
                            end
                         case 1
                            if i == n/size(firstRow,2) && j == size(firstRow,2)
                                searchPool = corner0Tab;
                            elseif i == n/size(firstRow,2)
                                searchPool = [edge0Tab, edge1TabLeft];
                            elseif j == size(firstRow,2)
                                searchPool = [edge1TabLeft, edge1TabRight];
                            else
                                searchPool = [internal0Tab, internal1Tab, internal2TabAdjacent];
                            end
                    end
            end
            incompatibilities = int16.empty(0,3);
            for a = 1:size(searchPool,2)
                for b = 1:4
                    if searchPool(a).splicedOn == 0 && searchPool(a).edges(b).type + leftNotch.type == 0 && searchPool(a).edges(mod((b+1)-1,4)+1).type + topNotch.type == 0 && abs(searchPool(a).edges(b).endpointsDistance - leftNotch.endpointsDistance) <= distanceSensitivity && abs(searchPool(a).edges(mod((b+1)-1,4)+1).endpointsDistance - topNotch.endpointsDistance) <= distanceSensitivity
                        leftIncompatibility = getIncompatibleArea(leftNotch, searchPool(a).edges(b), puzzle(i,j-1).afterRotation(2), b);
                        topIncompatibility = getIncompatibleArea(topNotch, searchPool(a).edges(mod((b+1)-1,4)+1), puzzle(i-1,j).afterRotation(3), mod((b+1)-1,4)+1);
                        incompatibility = leftIncompatibility + topIncompatibility;
                        incompatibilities = [incompatibilities; incompatibility, a, b];
                    end
                end
            end
            if isempty(incompatibilities)
                fprintf('Cannot find a puzzle piece for position (%d,%d)\n',i,j);
                fprintf('Currently the puzzle is: \n');
                disp(puzzleNumOnly);
                fprintf('Please follow the above to splice the puzzle from left to right, from top to bottom, and enter where the error started.\n');
                r = input('Plase enter the row number of the error: ');
                c = input('Plase enter the col number of the error: ');
                fprintf('\nBack to position (%d,%d)...\n', r, c);
                for a = i:-1:r
                    for b = size(firstRow,2):-1:1
                        if a ~= r || b >= c
                            puzzle(a,b).splicedOn = 0;
                            puzzle(a,b).afterRotation = [1,2,3,4];
                            puzzleNumOnly(a,b) = 0;
                        end
                    end
                end
                i = r;
                j = c;
                errorCorrection = 1;
                continue;
            end
            if i == n/size(firstRow,2) && j == size(firstRow,2)
                fprintf('Almost completed!\n');
                fprintf('Currently the puzzle is: \n');
                disp(puzzleNumOnly);
                fprintf('Please follow the above to splice the puzzle from left to right, from top to bottom.\n');
                error = input('If you find any errors, please enter 1, otherwise enter 0: ');
                if error
                    r = input('Plase enter the row number of the error started: ');
                    c = input('Plase enter the col number of the error started: ');
                    fprintf('\nBack to position (%d,%d)...\n', r, c);
                    for a = i:-1:r
                        for b = size(firstRow,2):-1:1
                            if a ~= r || b >= c
                                puzzle(a,b).splicedOn = 0;
                                puzzle(a,b).afterRotation = [1,2,3,4];
                                puzzleNumOnly(a,b) = 0;
                            end
                        end
                    end
                    i = r;
                    j = c;
                    errorCorrection = 1;
                    continue;
                end
            end
            incompatibilities = sortrows(incompatibilities,1);
            candidates = incompatibilities(1,:);
            if errorCorrection
                fprintf('\nError Correction:\n');
                fprintf('Plase selecte a puzzle piece for position (%d,%d)\n',i,j);
                fprintf('The following are the candidate puzzle pieces and their incompatibility: \n');
                for a = 1:size(incompatibilities,1)
                    fprintf('Index: %d | Puzzle pieces: %d | Incompatibility: %d\n', a, searchPool(incompatibilities(a,2)).num, incompatibilities(a,1));
                end
                x = input('enter the index of the puzzle pieces selected: ');
                selected = incompatibilities(x,:);
                errorCorrection = 0;
                fprintf('\n------------------------------------------------------\n\n');
            else
                selected = incompatibilities(1,:);
            end
            puzzle(i,j) = searchPool(selected(2));
            puzzle(i,j).afterRotation = [mod((selected(3)+1)-1,4)+1,mod((selected(3)+2)-1,4)+1,mod((selected(3)+3)-1,4)+1,selected(3)];
            puzzle(i,j).splicedOn = 1;
            puzzleNumOnly(i,j) = searchPool(selected(2)).num;
        end
        if ~errorCorrection
            j = j + 1;
        end
    end
    if ~errorCorrection
        fprintf('\nRow %d completed.\n', i);
        fprintf('Currently the puzzle is: \n');
        disp(puzzleNumOnly);
        fprintf('\n------------------------------------------------------\n\n');
        i = i + 1;
    end
end

fprintf('Assemble completed!\n');
fprintf('The puzzle is: \n');
disp(puzzleNumOnly);
