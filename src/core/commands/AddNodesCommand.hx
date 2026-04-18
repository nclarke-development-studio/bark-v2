package core.commands;

import data.NodeData;

class AddNodesCommand implements ICommand {
	var graph:Graph;
	var nodes:Array<NodeData>;

	public function new(g:Graph, n:Array<NodeData>) {
		graph = g;
		nodes = n;
	}

	public function execute() {
		for (node in nodes) {
			graph.addNode(node);
		}
	}

	public function undo()
		for (node in nodes) {
			graph.removeNode(node.id);
		}
}
