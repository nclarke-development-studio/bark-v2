package util;

import data.GraphData;
import data.NodeData;
import data.ConnectionData;
import data.PortData;
import haxe.ui.util.GUID;

class StressTest {
    public static function generate(count:Int):GraphData {
        var graph:GraphData = {
            nodes: [],
            connections: []
        };

        var cols = Std.int(Math.sqrt(count));
        var spacingX = 300;
        var spacingY = 200;

        for (i in 0...count) {
            var nodeId = GUID.uuid();
            var outPortId = GUID.uuid();
            var inPortId = GUID.uuid();

            // Create the node structure based on your provided sample
            var node:NodeData = {
                id: nodeId,
                type: "basic",
                x: (i % cols) * spacingX,
                y: Math.floor(i / cols) * spacingY,
                fields: [],
                ports: [
                    {
                        id: outPortId,
                        name: "mainSource",
                        direction: PortDirection.Output,
                        isMain: true
                    },
                    {
                        id: inPortId,
                        name: "mainTarget",
                        direction: PortDirection.Input,
                        isMain: true
                    }
                ]
            };

            graph.nodes.push(node);

            // Connect this node to the previous node to stress the edge renderer
            if (i > 0) {
                var prevNode = graph.nodes[i - 1];
                var prevOutPort = prevNode.ports[0].id; // mainSource

                graph.connections.push({
                    id: GUID.uuid(),
                    fromNode: prevNode.id,
                    fromPort: prevOutPort,
                    toNode: nodeId,
                    toPort: inPortId,
                    fields: []
                });
            }
        }

        return graph;
    }
}