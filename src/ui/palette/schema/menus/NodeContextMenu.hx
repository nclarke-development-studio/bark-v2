package ui.palette.schema.menus;

import ui.components.ContextMenu;
import util.WorkspaceUtils;
import core.EditorSession;
import ui.nodes.NodeView;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class NodeContextMenu extends ContextMenu {
	public function new(node:NodeView, session:EditorSession) {
		super();

		addItem("Duplicate Node", _ -> {
			session.duplicateNode(node.data);
		});

		addItem("Delete Node", _ -> {
			session.removeNode(node.data.id);
		});
	}
}
