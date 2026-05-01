package core.commands;

import data.ConnectionData;

// a small structure to track both the item and where it lived
typedef RemovedConnection = {
    var index:Int;
    var data:ConnectionData;
}

class RemoveConnectionsCommand implements ICommand {
    var graph:Graph;
    var targets:Array<ConnectionData>;
    var removedRecords:Array<RemovedConnection>;

    public function new(graph:Graph, connections:Array<ConnectionData>) {
        this.graph = graph;
        this.targets = connections.copy();
        this.removedRecords = [];
    }

    public function execute():Void {
        removedRecords = [];

        for (connection in targets) {
            var index = graph.data.connections.indexOf(connection);            
            // only act if the connection actually exists in the graph
            if (index != -1) {
                removedRecords.push({ index: index, data: connection });
                graph.data.connections.splice(index, 1);
            }
        }
    }

    public function undo():Void {
        var i = removedRecords.length - 1;
        while (i >= 0) {
            var record = removedRecords[i];
            graph.data.connections.insert(record.index, record.data);
            i--;
        }
    }
}