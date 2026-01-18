package core.commands;

import data.NodeData;

class RemoveNodeCommand implements ICommand {
	var graph:Graph;
	var node:NodeData;

	public function new(g:Graph, n:NodeData) {
		graph = g;
		node = n;
	}

	public function execute()
		graph.removeNode(node.id);

	public function undo()
		graph.addNode(node);
}
