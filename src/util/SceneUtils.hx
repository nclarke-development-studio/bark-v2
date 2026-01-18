package util;

import data.ConnectionData;
import data.NodeData;
import data.GraphData;

class SceneUtils {
	public static function cloneGraph(graph:GraphData):GraphData {
		return {
			nodes: graph.nodes.map(cloneNode),
			connections: graph.connections.map(cloneConnection)
		};
	}

	static function cloneNode(n:NodeData):NodeData {
		return {
			id: haxe.ui.util.GUID.uuid(),
			type: n.type,
			x: n.x,
			y: n.y,
			ports: n.ports.map(p -> ({
				id: haxe.ui.util.GUID.uuid(),
				name: p.name,
				direction: p.direction,
				isMain: p.isMain
			})),
			fields: haxe.Json.parse(haxe.Json.stringify(n.fields))
		};
	}

	static function cloneConnection(c:ConnectionData):ConnectionData {
		return {
			id: haxe.ui.util.GUID.uuid(),
			fromNode: c.fromNode,
			toNode: c.toNode,
			fromPort: c.fromPort,
			toPort: c.toPort
		};
	}
}
