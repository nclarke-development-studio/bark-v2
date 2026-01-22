package core;

import util.ArrayUtils;
import data.*;

class Graph {
	public var data:GraphData;

	public function new(?g:GraphData) {
		if (g != null)
			data = g;
		else
			data = {nodes: [], connections: []};
	}

	public function addNode(n:NodeData) {
		data.nodes.push(n);
	}

	public function removeNode(id:String) {
		data.nodes = data.nodes.filter(n -> n.id != id);
		data.connections = data.connections.filter(c -> !usesNode(c, id));
	}

	public function getNode(id:String) {
		var node = ArrayUtils.find(data.nodes, n -> n.id == id);
		return node;
	}

	public function addConnection(c:ConnectionData) {
		data.connections.push(c);
	}

	public function removeConnection(id:String) {
		data.connections = data.connections.filter(c -> c.id != id);
	}

	function usesNode(c:ConnectionData, id:String):Bool {
		return c.fromNode.indexOf(id) != -1 || c.toNode.indexOf(id) != -1;
	}
}
