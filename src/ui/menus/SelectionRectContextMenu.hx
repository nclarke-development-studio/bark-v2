package ui.menus;

import ui.nodes.NodeView;
import ui.components.ContextMenu;
import util.WorkspaceUtils;
import core.EditorSession;
import ui.canvas.NodeCanvas;

class SelectionRectContextMenu extends ContextMenu {
	public function new(c:NodeCanvas, nodes: Array<NodeView>, session:EditorSession) {
		super();

		// TODO: open schema menu to name
		addItem("Save Node(s)", _ -> {
			var nodes = nodes.map(n -> n.data);
			session.addSchemaToWorkspace(WorkspaceUtils.encodeSchema('test', '', nodes, session.graph.data.connections));
		});

		addItem("Duplicate Node(s)", _ -> {
			session.duplicateNodes(nodes.map(n -> n.data));
		});

		addItem("Delete Node(s)", _ -> {
			var ids = nodes.map(n -> n.data.id);
			session.removeNodes(ids);
			c.selection.endSelection();
		});
	}
}
