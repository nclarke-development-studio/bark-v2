package core.commands;

import haxe.ui.util.GUID;
import data.PortData;
import data.NodeData;

class AddPortCommand implements ICommand {
	var node:NodeData;
	var port:PortData;

	public function new(node:NodeData, d:PortData) {
		this.node = node;
		this.port = d;
	}

	public function execute():Void {
		// node.ports.push(port);
	}

	public function undo():Void {
		// node.ports.remove(port);
	}
}
