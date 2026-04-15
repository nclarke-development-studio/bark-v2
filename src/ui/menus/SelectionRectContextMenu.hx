package ui.menus;

import util.WorkspaceUtils;
import core.EditorSession;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class SelectionRectContextMenu extends Menu {
	public function new(c:NodeCanvas, session:EditorSession) {
		super();

		// TODO: open schema menu to name
		var saveNodesItem = new MenuItem();
		saveNodesItem.text = "Save Node(s)";
		saveNodesItem.onClick = _ -> {
			var nodes = c.selectedNodes.map(n -> n.data);
			session.addSchemaToWorkspace(WorkspaceUtils.encodeSchema('test', '', nodes, session.graph.data.connections));
		};
		addComponent(saveNodesItem);

		var duplicateNodesItem = new MenuItem();
		duplicateNodesItem.text = "Duplicate Node(s)";
		duplicateNodesItem.onClick = _ -> {
			// trace(session.createSchema(name, c.selectedNodes));
		};
		addComponent(duplicateNodesItem);

		var deleteNodesItem = new MenuItem();
		deleteNodesItem.text = "Delete Node(s)";
		deleteNodesItem.onClick = _ -> {
			var ids = c.selectedNodes.map(n -> n.data.id);
			session.removeNodes(ids);
			c.selection.endSelection();
		};
		addComponent(deleteNodesItem);
	}
}
