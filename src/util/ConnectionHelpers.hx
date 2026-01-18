package util;

import haxe.ds.Map;
import ui.nodes.NodeView;
import ui.connections.ConnectionView;

class ConnectionHelpers {

    /**
     * Returns all edges coming into a node.
     * @param edgesIntoMap The map from node IDs to incoming connections.
     */
    public static function getEdgesInto(node:NodeView, edgesIntoMap:Map<String, Array<ConnectionView>>):Array<ConnectionView> {
        return edgesIntoMap.exists(node.data.id) ? edgesIntoMap[node.data.id] : [];
    }

    /**
     * Returns all edges going out of a node.
     * @param edgesOutMap The map from node IDs to outgoing connections.
     */
    public static function getEdgesOut(node:NodeView, edgesOutMap:Map<String, Array<ConnectionView>>):Array<ConnectionView> {
        return edgesOutMap.exists(node.data.id) ? edgesOutMap[node.data.id] : [];
    }
}
