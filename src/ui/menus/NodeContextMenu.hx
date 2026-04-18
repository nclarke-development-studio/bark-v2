package ui.menus;

import ui.components.ContextMenu;
import ui.canvas.NodeCanvas;
import ui.nodeeditor.NodeEditor;
import util.WorkspaceUtils;
import core.EditorSession;
import ui.nodes.NodeView;

class NodeContextMenu extends ContextMenu {
	public function new(node:NodeView, session:EditorSession, canvas:NodeCanvas) {
		super();

		// TODO: open schema name menu
		addItem("Save Node", _ -> {
			session.addSchemaToWorkspace(WorkspaceUtils.encodeSchema('test', '', [node.data], session.graph.data.connections));
		});

		addItem("Open Node", _ -> {
			var dialog = new NodeEditor(canvas, node);
			dialog.showDialog();
		});

		addItem("Duplicate Node", _ -> {
			session.duplicateNode(node.data);
		});

		addItem("Delete Node", _ -> {
			session.removeNode(node.data.id);
		});
	}
}
