package ui.menus;

import ui.canvas.CanvasSelection;
import core.EditorSession;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class SelectionRectContextMenu extends Menu {
	public function new(c:NodeCanvas, session:EditorSession) {
		super();

		var saveNodesItem = new MenuItem();
		saveNodesItem.text = "Save Node(s)";
		saveNodesItem.onClick = _ -> {
			// trace(session.createSchema(name, c.selectedNodes));
		};
		addComponent(saveNodesItem);

		var deleteNodes = new MenuItem();
		deleteNodes.text = "Delete Node(s)";
		deleteNodes.onClick = _ -> {
			trace('delete nodes');
		};
		addComponent(deleteNodes);
	}
}
