package util;

import data.ConnectionData;
import haxe.ds.Map;
import ui.nodes.NodeView;
import ui.connections.ConnectionView;

class ConnectionHelpers {
	/**
	 * Returns all edges coming into a node.
	 * @param edgesIntoMap The map from node IDs to incoming connections.
	 */
	public static function getEdgesInto(id:String, edgesIntoMap:Map<String, Array<ConnectionView>>):Array<ConnectionView> {
		return edgesIntoMap.exists(id) ? edgesIntoMap[id] : [];
	}

	/**
	 * Returns all edges going out of a node.
	 * @param edgesOutMap The map from node IDs to outgoing connections.
	 */
	public static function getEdgesOut(id:String, edgesOutMap:Map<String, Array<ConnectionView>>):Array<ConnectionView> {
		return edgesOutMap.exists(id) ? edgesOutMap[id] : [];
	}

	public static function getIncomingNodes(node:NodeView, edgesInto:Map<String, Array<ConnectionView>>):Array<NodeView> {
		var result:Array<NodeView> = [];
		if (!edgesInto.exists(node.data.id))
			return result;

		for (c in edgesInto[node.data.id]) {
			result.push(c.fromNode);
		}
		return result;
	}

	public static function getOutgoingNodes(node:NodeView, edgesOut:Map<String, Array<ConnectionView>>):Array<NodeView> {
		var result:Array<NodeView> = [];
		if (!edgesOut.exists(node.data.id))
			return result;

		for (c in edgesOut[node.data.id]) {
			result.push(c.toNode);
		}
		return result;
	}
}
