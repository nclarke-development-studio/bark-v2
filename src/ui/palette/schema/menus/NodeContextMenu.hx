package ui.palette.schema.menus;

import util.WorkspaceUtils;
import core.EditorSession;
import ui.nodes.NodeView;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class NodeContextMenu extends Menu {
	public function new(node:NodeView, session:EditorSession) {
		super();

		var duplicateItem = new MenuItem();
		duplicateItem.text = "Duplicate Node";
		duplicateItem.onClick = _ -> {
			session.duplicateNode(node.data);
		};

		var deleteItem = new MenuItem();
		deleteItem.text = "Delete Node";
		deleteItem.onClick = _ -> {
			session.removeNode(node.data.id);
		};

		addComponent(duplicateItem);
		addComponent(deleteItem);
	}
}
