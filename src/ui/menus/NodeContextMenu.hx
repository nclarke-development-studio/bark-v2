package ui.menus;

import ui.canvas.NodeCanvas;
import ui.nodeeditor.NodeEditor;
import util.WorkspaceUtils;
import core.EditorSession;
import ui.nodes.NodeView;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class NodeContextMenu extends Menu {
	public function new(node:NodeView, session:EditorSession, canvas:NodeCanvas) {
		super();

		// TODO: open schema name menu
		var saveItem = new MenuItem();
		saveItem.text = "Save Node";
		saveItem.onClick = _ -> {
			session.addSchemaToWorkspace(WorkspaceUtils.encodeSchema('test', '', [node.data], session.graph.data.connections));
		};

		var focusItem = new MenuItem();
		focusItem.text = "Open Node";
		focusItem.onClick = _ -> {
			var dialog = new NodeEditor(canvas, node);
			dialog.showDialog();
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

		addComponent(focusItem);
		addComponent(saveItem);
		addComponent(duplicateItem);
		addComponent(deleteItem);
	}
}
