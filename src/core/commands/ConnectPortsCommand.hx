package core.commands;

import data.ConnectionData;

class ConnectPortsCommand implements ICommand {
	var graph:Graph;
	public var connection:ConnectionData;

	public function new(graph:Graph, d:ConnectionData) {
		this.graph = graph;
		this.connection = d;
	}

	public function execute():Void {
		graph.data.connections.push(connection);
	}

	public function undo():Void {
		graph.data.connections.remove(connection);
	}
}
