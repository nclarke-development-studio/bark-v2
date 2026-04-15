package ui.menus;

import ui.connectionEditor.ConnectionEditor;
import data.ConnectionData;
import ui.canvas.NodeCanvas;
import core.EditorSession;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class ConnectionContextMenu extends Menu {
	public function new(edge:ConnectionData, session:EditorSession, canvas:NodeCanvas) {
		super();

		var focusItem = new MenuItem();
		focusItem.text = "Open Edge";
		focusItem.onClick = _ -> {
			var dialog = new ConnectionEditor(canvas, edge);
			dialog.showDialog();
		};

		var deleteItem = new MenuItem();
		deleteItem.text = "Delete Edge";
		deleteItem.onClick = _ -> {
			session.removeConnection(edge);
		};

		addComponent(focusItem);
		addComponent(deleteItem);
	}
}
