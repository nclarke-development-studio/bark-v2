package ui.menus;

import util.WorkspaceUtils;
import core.Workspace;
import core.EditorSession;
import ui.nodes.NodeView;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class NodeContextMenu extends Menu {
	public function new(node:NodeView, session:EditorSession) {
		super();

		// TODO: open schema name menu
		var saveItem = new MenuItem();
		saveItem.text = "Save Node";
		saveItem.onClick = _ -> {
			session.addNodeToWorkspace(WorkspaceUtils.encodeSchema('test', '', [node.data], session.graph.data.connections));
		};

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

		addComponent(saveItem);
		addComponent(duplicateItem);
		addComponent(deleteItem);
	}
}
