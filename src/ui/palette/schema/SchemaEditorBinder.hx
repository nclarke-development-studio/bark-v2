package ui.palette.schema;

import ui.menus.ConnectionContextMenu;
import ui.nodes.NodeView;
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

	var canvasContextMenu:GraphContextMenu;
	var nodeContextMenu:NodeContextMenu;
	var connectionContextMenu:ConnectionContextMenu;
	var selectionContextMenu:SelectionRectContextMenu;

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
			canvas.onRequestCanvasContextMenu = (canvas, x, y) -> {
				if (canvasContextMenu != null) {
					canvasContextMenu.hide();
				}
				canvasContextMenu = new GraphContextMenu(canvas, session, schema, close);
				canvasContextMenu.left = x;
				canvasContextMenu.top = y;
				canvasContextMenu.show();
			};

			canvas.onRequestNodeContextMenu = (canvas, x, y) -> {
				if (nodeContextMenu != null) {
					nodeContextMenu.hide();
				}
				nodeContextMenu = new NodeContextMenu(canvas, session);
				nodeContextMenu.left = x;
				nodeContextMenu.top = y;
				nodeContextMenu.show();
			}

			canvas.onRequestConnectionContextMenu = (connection, x, y) -> {
				if (connectionContextMenu != null) {
					connectionContextMenu.hide();
				}
				connectionContextMenu = new ConnectionContextMenu(connection, session, canvas);
				connectionContextMenu.left = x;
				connectionContextMenu.top = y;
				connectionContextMenu.show();
			}

			canvas.onRequestSelectionContextMenu = (c, x, y) -> {
				if (selectionContextMenu != null) {
					selectionContextMenu.hide();
				}
				selectionContextMenu = new SelectionRectContextMenu(c, session);
				selectionContextMenu.left = x;
				selectionContextMenu.top = y;
				selectionContextMenu.show();
			}

			canvas.onRequestNodesDelete = (nodes:Array<NodeView>) -> {
				var ids = nodes.map(n -> n.data.id);
				session.removeNodes(ids);
			}

			canvas.onRemoveConnection = (c) -> {
				session.removeConnection(c);
			}

			canvas.onRequestNodeCreate = (s, x, y) -> {
				var dropPosition = canvas.contentLayer.globalToLocal(new openfl.geom.Point(x, y));
				var nodes = session.createNodes(s, dropPosition.x, dropPosition.y);

				// select the nodes afterwards
				for (n in nodes) {
					var view = canvas.getNodeView(n.id);
					if (view != null) {
						canvas.selectNode(view);
					}
				}

				return nodes;
			}

			canvas.onRequestUndo = () -> {
				session.undo();
			}

			canvas.onRequestRedo = () -> {
				session.redo();
			}

			canvas.connectPorts = session.connectPorts;

			canvas.init();
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
