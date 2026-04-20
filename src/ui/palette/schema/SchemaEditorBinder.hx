package ui.palette.schema;

import util.WorkspaceUtils;
import ui.dialogs.NewSchemaDialog;
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
					canvasContextMenu.close();
				}
				canvasContextMenu = new GraphContextMenu(canvas, session, schema, close);
				canvasContextMenu.left = x;
				canvasContextMenu.top = y;
				canvas.addComponent(canvasContextMenu);
			};

			canvas.onRequestNodeContextMenu = (canvas, x, y) -> {
				if (nodeContextMenu != null) {
					nodeContextMenu.close();
				}
				nodeContextMenu = new NodeContextMenu(canvas, session);
				nodeContextMenu.left = x;
				nodeContextMenu.top = y;
				canvas.addComponent(nodeContextMenu);
			}

			canvas.onRequestConnectionContextMenu = (connection, x, y) -> {
				if (connectionContextMenu != null) {
					connectionContextMenu.close();
				}
				connectionContextMenu = new ConnectionContextMenu(connection, session, canvas);
				connectionContextMenu.left = x;
				connectionContextMenu.top = y;
				canvas.addComponent(connectionContextMenu);
			}

			canvas.onRequestSelectionContextMenu = (c, n, x, y) -> {
				if (selectionContextMenu != null) {
					selectionContextMenu.close();
				}
				selectionContextMenu = new SelectionRectContextMenu(c, n, session);
				selectionContextMenu.left = x;
				selectionContextMenu.top = y;
				canvas.addComponent(selectionContextMenu);
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

			palette.onRequestSaveSchema = () -> {
				var dialog = new NewSchemaDialog(session.workspace);

				if (schema != null) {
					dialog.schemaNameText = schema.name;
				}
				dialog.onConfirm = name -> {
					if (schema != null)
						session.removeSchemaFromWorkspace(schema.name);

					var newSchema = WorkspaceUtils.encodeSchema(name, '', session.graph.data.nodes, session.graph.data.connections);

					if (close != null && newSchema != null)
						close(newSchema);
				};
				dialog.showDialog();
			}

			palette.init();
			palette.rebuild(session.workspace);
		}
	}
}
