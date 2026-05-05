package core.commands;

import data.ConnectionData;

class ConnectMultiplePortsCommand implements ICommand {
	var graph:Graph;

	public var connections:Array<ConnectionData>;

	public function new(graph:Graph, d:Array<ConnectionData>) {
		this.graph = graph;
		this.connections = d.copy();
	}

	public function execute():Void {
		for (connection in connections) {
			graph.data.connections.push(connection);
		}
	}

	public function undo():Void {
		for (connection in connections) {
			graph.data.connections.remove(connection);
		}
	}
}
