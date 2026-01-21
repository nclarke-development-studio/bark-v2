package ui.menus;

import ui.nodes.NodeView;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class NodeContextMenu extends Menu {
	public function new(node:NodeView, controller:EditorController) {
		super();

		// TODO: open schema name menu
		var saveItem = new MenuItem();
		saveItem.text = "Save Node";
		saveItem.onClick = _ -> {
			controller.createSchema(node.data.id, [node.data], controller.graph.data.connections);
		};

		var duplicateItem = new MenuItem();
		duplicateItem.text = "Duplicate Node";
		duplicateItem.onClick = _ -> {
			controller.duplicateNode(node);
		};

		var deleteItem = new MenuItem();
		deleteItem.text = "Delete Node";
		deleteItem.onClick = _ -> {
			controller.deleteNode(node);
		};

		addComponent(saveItem);
		addComponent(duplicateItem);
		addComponent(deleteItem);
	}
}
