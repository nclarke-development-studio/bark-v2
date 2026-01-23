package ui.palette.schema;

import data.NodeData.NodeGroupSchema;
import ui.palette.schema.menus.SelectionRectContextMenu;
import ui.palette.schema.menus.NodeContextMenu;
import ui.palette.schema.menus.GraphContextMenu;
import ui.canvas.NodeCanvas;
import core.EditorSession;

class SchemaEditorBinder {
	var session:EditorSession;
	var canvas:NodeCanvas;
	var palette:SchemaEditorPalette;
	var schema:NodeGroupSchema;
	var close:(NodeGroupSchema) -> Void;

	public function new(s:EditorSession, ?c:NodeCanvas, ?p:SchemaEditorPalette, ?schema:NodeGroupSchema, ?close:(NodeGroupSchema) -> Void) {
		session = s;
		canvas = c;
		palette = p;
		this.schema = schema;
		this.close = close;

		// canvas.onRequestAddNode = (x, y) -> {
		// 	session.addNode(makeNodeAt(x, y));
		// };

		session.onChanged = (change) -> {
			switch (change) {
				case GraphChanged:
					if (canvas != null) canvas.rebuild(session.graph);
				case WorkspaceChanged:
					if (palette != null) palette.rebuild(session.workspace);
			}
		};

		init();
	}

	function init() {
		if (canvas != null) {
			// canvas binding
			canvas.onRequestCanvasContextMenu = (canvas, e) -> {
				var menu = new GraphContextMenu(canvas, session, schema, close);
				menu.left = e.screenX;
				menu.top = e.screenY;
				menu.show();
			};

			canvas.onRequestNodeContextMenu = (canvas, e) -> {
				var menu = new NodeContextMenu(canvas, session);
				menu.left = e.screenX;
				menu.top = e.screenY;
				menu.show();
			}

			canvas.onRequestSelectionContextMenu = (c, e) -> {
				var menu = new SelectionRectContextMenu(c, session);
				menu.left = e.screenX;
				menu.top = e.screenY;
				menu.show();
			}

			canvas.onRemoveConnection = (c) -> {
				session.removeConnection(c);
			}

			canvas.connectPorts = session.connectPorts;
		}

		if (palette != null) {
			palette.onRequestNodeDrop = (s, x, y) -> {
				var dropPosition = canvas.contentLayer.globalToLocal(new openfl.geom.Point(x, y));
				var nodes = session.createNodes(s, dropPosition.x, dropPosition.y);

				// select the nodes afterwards
				for (n in nodes) {
					var view = canvas.getNodeView(n.id);
					if (view != null) {
						canvas.selectNode(view);
					}
				}
			}

			palette.init();
			palette.rebuild(session.workspace);
		}
	}
}
