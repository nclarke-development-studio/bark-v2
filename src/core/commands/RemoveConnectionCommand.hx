package core.commands;

import data.ConnectionData;

class RemoveConnectionCommand implements ICommand {
	var graph:Graph;
	var connection:ConnectionData;
	var index:Int;

	public function new(graph:Graph, connection:ConnectionData) {
		this.graph = graph;
		this.connection = connection;
	}

	public function execute():Void {
		index = graph.data.connections.indexOf(connection);
		if (index != -1) {
			graph.data.connections.splice(index, 1);
		}
	}

	public function undo():Void {
		if (index >= 0) {
			graph.data.connections.insert(index, connection);
		}
	}
}
