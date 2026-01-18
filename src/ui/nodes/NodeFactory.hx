package ui.nodes;

import data.NodeData;

class NodeFactory {
	public static function createNode(d:NodeData, e:EditorController):NodeView {
		return new NodeView(d, e);
	}
}
