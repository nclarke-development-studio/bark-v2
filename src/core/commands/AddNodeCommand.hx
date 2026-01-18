package core.commands;

import data.NodeData;

class AddNodeCommand implements ICommand {
	var graph:Graph;
	var node:NodeData;

	public function new(g:Graph, n:NodeData) {
		graph = g;
		node = n;
	}

	public function execute()
		graph.addNode(node);

	public function undo()
		graph.removeNode(node.id);
}
