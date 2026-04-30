package core.commands;

import data.ConnectionData;

class RemoveConnectionsCommand implements ICommand {
	var graph:Graph;
	var connections:Array<ConnectionData>;
	var indeces:Array<Int>;

	public function new(graph:Graph, connections:Array<ConnectionData>) {
		this.graph = graph;
		this.connections = connections;
		this.indeces = [];
	}

	public function execute():Void {
		for (connection in connections){
			var index = graph.data.connections.indexOf(connection);
			if (index != -1) {
				graph.data.connections.splice(index, 1);
			}
			indeces.push(index);
		}
	}

	// TODO: bug check this
	public function undo():Void {
		for(i in 0...connections.length){
			var index = indeces[i];
			if (indeces[i] >= 0) {
				graph.data.connections.insert(index, connections[i]);
			}
		}
	}
}
