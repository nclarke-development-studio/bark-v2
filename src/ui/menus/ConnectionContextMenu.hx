package ui.menus;

import ui.components.ContextMenu;
import ui.connectionEditor.ConnectionEditor;
import data.ConnectionData;
import ui.canvas.NodeCanvas;
import core.EditorSession;

class ConnectionContextMenu extends ContextMenu {
	public function new(edge:ConnectionData, session:EditorSession, canvas:NodeCanvas) {
		super();

		addItem("Open Edge", _ -> {
			var dialog = new ConnectionEditor(canvas, edge);
			dialog.showDialog();
		});

		addItem("Delete Edge", _ -> {
			session.removeConnection(edge);
		});
	}
}
