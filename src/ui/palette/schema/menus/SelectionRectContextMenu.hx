package ui.palette.schema.menus;

import ui.nodes.NodeView;
import ui.components.ContextMenu;
import core.EditorSession;
import ui.canvas.NodeCanvas;

class SelectionRectContextMenu extends ContextMenu {
	public function new( c:NodeCanvas, nodes: Array<NodeView>, session:EditorSession) {
		super();

		addItem("Duplicate Node(s)", _ -> {
			session.duplicateNodes(nodes.map(n -> n.data));
		});

		addItem("Delete Node(s)", _ -> {
			session.removeNodes(nodes.map(n -> n.data.id));
		});
	}
}
