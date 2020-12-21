classdef PuzzlePiece < handle
    properties
        num;
        image;
        edges;
        type;
        afterRotation;
        splicedOn;
    end
    
    methods
        function obj = PuzzlePiece(num,image,edges)
            if nargin > 0
                obj.num = num;
                obj.image = image;
                obj.edges = edges;
                edgeType = [edges(1).type, edges(2).type, edges(3).type, edges(4).type,];
                obj.splicedOn = 0;
                obj.afterRotation = 0;
                numOfTabs = 0;
                numOfFlatEdges = 0;
                for i = 1:4
                    switch edgeType(i)
                        case 0
                            numOfFlatEdges= numOfFlatEdges+1;
                        case 1
                            numOfTabs= numOfTabs+1;
                    end
                end
                switch numOfFlatEdges
                    case 2
                        switch numOfTabs
                            case 0
                                obj.type = '0-tab corner piece';
                            case 1
                                obj.type = '1-tab corner piece';
                            case 2
                                obj.type = '2-tab corner piece';
                        end
                    case 1
                        switch numOfTabs
                            case 0
                            obj.type = '0-tab edge piece';
                            case 1
                                for i = 1:4
                                    if edgeType(i) == 0
                                        if edgeType(mod((i-1)-1,4)+1) == 1
                                            obj.type = '1-left-tab edge piece';
                                        elseif edgeType(mod((i-1)+1,4)+1) == 1
                                            obj.type = '1-right-tab edge piece';
                                        else
                                            obj.type = '1-down-tab edge piece';
                                        end
                                    end
                                end
                            case 2
                                for i = 1:4
                                    if edgeType(i) == 0
                                        if edgeType(mod((i-1)-1,4)+1) == -1
                                            obj.type = '2-right-tab edge piece';
                                        elseif edgeType(mod((i-1)+1,4)+1) == -1
                                            obj.type = '2-left-tab edge piece';
                                        else
                                            obj.type = '2-oppsite-tab edge piece';
                                        end
                                    end
                                end
                            case 3
                                obj.type = '3-tab edge piece';
                        end
                    case 0
                        switch numOfTabs
                            case 0
                                obj.type = '0-tab internal piece';
                            case 1
                                obj.type = '1-tab internal piece';
                            case 2
                                for i = 1:4
                                    if edgeType(i) == 1
                                        if edgeType(mod((i-1)-2,4)+1) == 1
                                            obj.type = '2-opposite-tab internal piece';
                                        else
                                            obj.type = '2-adjacent-tab internal piece';
                                        end
                                    end
                                end
                            case 3
                                obj.type = '3-tab internal piece';
                            case 4
                                obj.type = '4-tab internal piece';
                        end
                end
            end
        end
    end
end