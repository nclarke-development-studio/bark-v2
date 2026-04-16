package core.commands;

import data.NodeData;

class RemoveNodesCommand implements ICommand {
	var graph:Graph;
	var nodes:Array<NodeData>;

	public function new(g:Graph, nds:Array<NodeData>) {
		graph = g;
		nodes = nds;
	}

	public function execute()
		for (node in nodes) {
			graph.removeNode(node.id);
		}

	public function undo()
		for (node in nodes) {
			graph.addNode(node);
		}
}
