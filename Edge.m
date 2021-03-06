classdef Edge
    properties
        edgeIm,
        type,
        endpoints,
        endpointsDistance
    end
    
    methods
        function obj = Edge(edgeIm,type,endpoints)
            obj.edgeIm = edgeIm;
            obj.type = type;
            obj.endpoints = endpoints;
            obj.endpointsDistance = sqrt(power((endpoints(1,1)-endpoints(2,1)),2)+power((endpoints(1,2)-endpoints(2,2)),2));
        end
    end
end