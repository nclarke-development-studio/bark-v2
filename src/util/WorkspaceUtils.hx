package util;

import data.PortData;
import haxe.ui.util.GUID;
import data.ConnectionData;
import data.NodeData;
import data.GraphData;

class WorkspaceUtils {
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

	static function buildPortKeyMap(n:NodeData):Map<String, String> {
		var map = new Map<String, String>();

		for (f in n.fields) {
			if (f.type == "data" && f.portId != null) {
				map.set(f.portId, f.key);
			}
		}

		// also allow named main ports
		for (p in n.ports) {
			// if (p.isMain) {
			// 	map.set(p.id, p.name);
			// }
			map.set(p.id, p.name);
		}

		return map;
	}

	public static function encodeSchema(name:String, color:String, nodes:Array<NodeData>, connections:Array<ConnectionData>):NodeGroupSchema {
		if (nodes.length == 0) {
			// TODO: Notification
			throw "Cannot encode empty schema";
		}

		var portKeyMaps = new Map<String, Map<String, String>>();
		var base = nodes[0];

		for (n in nodes) {
			if (n.x < base.x) {
				base = n;
			}
			portKeyMaps.set(n.id, buildPortKeyMap(n));
		}

		var baseX = base.x;
		var baseY = base.y;

		var idMap = new Map<String, Int>();
		var schemaNodes:Array<SchemaNode> = [];
		var schemaEdges:Array<SchemaEdge> = [];

		for (n in nodes) {
			var nodeIndex = schemaNodes.length;

			idMap.set(n.id, nodeIndex);

			schemaNodes.push({
				name: n.type,
				type: n.type,
				color: "#ffffff",
				position: [n.x - baseX, n.y - baseY],
				ports: n.ports,
				fields: encodeFields(n.fields)
			});
		}

		for (c in connections) {
			if (!idMap.exists(c.fromNode) || !idMap.exists(c.toNode))
				continue;

			var fromKey = portKeyMaps.get(c.fromNode).get(c.fromPort);
			var toKey = portKeyMaps.get(c.toNode).get(c.toPort);

			if (fromKey == null || toKey == null)
				continue;

			schemaEdges.push({
				from: idMap.get(c.fromNode),
				to: idMap.get(c.toNode),
				fromHandle: fromKey,
				toHandle: toKey
			});
		}

		return {
			name: name,
			color: color,
			nodes: schemaNodes,
			edges: schemaEdges
		};
	}

	public static function decodeSchema(schema:NodeGroupSchema, baseX:Float, baseY:Float):{nodes:Array<NodeData>, connections:Array<ConnectionData>} {
		var nodes:Array<NodeData> = [];
		var nodeIdMap = new Map<Int, String>();
		var portKeyMap = new Map<String, Map<String, String>>();

		for (i in 0...schema.nodes.length) {
			var sn = schema.nodes[i];
			var nodeId = GUID.uuid();

			var ports:Array<PortData> = [];
			var fields:Array<NodeField> = [];
			var keyToPort = new Map<String, String>();

			// main ports
			for (port in sn.ports) {
				var pid = GUID.uuid();
				ports.push({
					id: pid,
					name: port.name,
					direction: port.direction,
					isMain: true
				});
				keyToPort.set(port.name, pid);
			}

			// fields → ports
			if (sn.fields != null) {
				for (f in sn.fields) {
					var field:NodeField = {
						key: f.key,
						type: f.type,
						value: f.value,
						portId: null
					};

					if (f.type == "data") {
						var pid = GUID.uuid();
						// ports.push({
						// 	id: pid,
						// 	name: f.key,
						// 	direction: Output,
						// 	isMain: false
						// });
						field.portId = pid;
						keyToPort.set(f.key, pid);
					}

					fields.push(field);
				}
			}

			var nd:NodeData = {
				id: nodeId,
				type: sn.type,
				x: baseX + sn.position[0],
				y: baseY + sn.position[1],
				ports: ports,
				fields: fields
			};
			nodes.push(nd);
			nodeIdMap.set(i, nodeId);
			portKeyMap.set(nodeId, keyToPort);
		}

		var connections:Array<ConnectionData> = [];

		for (e in schema.edges) {
			var fromNodeId = nodeIdMap.get(e.from);
			var toNodeId = nodeIdMap.get(e.to);

			var fromPort = portKeyMap.get(fromNodeId).get(e.fromHandle);
			var toPort = portKeyMap.get(toNodeId).get(e.toHandle);

			connections.push({
				id: GUID.uuid(),
				fromNode: fromNodeId,
				toNode: toNodeId,
				fromPort: fromPort,
				toPort: toPort
			});
		}

		return {
			nodes: nodes,
			connections: connections
		};
	}

	static function encodeFields(fields:Array<Dynamic>):Array<SchemaField> {
		if (fields == null)
			return [];

		return fields.map(f -> {
			return {
				key: f.key,
				type: f.type,
				value: f.value
			};
		});
	}
}
