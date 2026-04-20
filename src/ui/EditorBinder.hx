package ui;

import ui.nodes.NodeView;
import ui.menus.ConnectionContextMenu;
import ui.menus.SelectionRectContextMenu;
import ui.menus.NodeContextMenu;
import ui.menus.GraphContextMenu;
import ui.toolbar.Toolbar;
import ui.palette.Palette;
import ui.canvas.NodeCanvas;
import core.EditorSession;

class EditorBinder {
	var session:EditorSession;
	var canvas:NodeCanvas;
	var palette:Palette;
	var toolbar:Toolbar;

	var canvasContextMenu:GraphContextMenu;
	var nodeContextMenu:NodeContextMenu;
	var connectionContextMenu:ConnectionContextMenu;
	var selectionContextMenu:SelectionRectContextMenu;

	public function new(s:EditorSession, ?c:NodeCanvas, ?p:Palette, ?t:Toolbar) {
		session = s;
		canvas = c;
		palette = p;
		toolbar = t;

		session.onChanged = (change) -> {
			switch (change) {
				case GraphChanged:
					if (canvas != null) canvas.rebuild(session.graph);
				case WorkspaceChanged:
					if (palette != null)
						palette.rebuild(session.workspace);
					if (toolbar != null) toolbar.rebuild(session.workspace);
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
					// canvas.removeComponent(canvasContextMenu);
					// canvasContextMenu.disposeComponent();
				}
				canvasContextMenu = new GraphContextMenu(canvas, session);
				canvasContextMenu.left = x;
				canvasContextMenu.top = y;
				canvas.addComponent(canvasContextMenu);
				// canvasContextMenu.onMenuSelected = _ -> {
				// 	// Screen.instance.removeComponent(canvasContextMenu);
				// 	// canvasContextMenu.hide();
				// 	// Screen.instance.invalidateAll();
				// 	// FocusManager.instance.focus = Screen.instance.rootComponents[0];
				// }
			};

			canvas.onRequestNodeContextMenu = (node, x, y) -> {
				if (nodeContextMenu != null) {
					nodeContextMenu.close();
				}
				nodeContextMenu = new NodeContextMenu(node, session, canvas);
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

			canvas.onRequestSave = () -> {
				session.saveWorkspace();
			}

			canvas.connectPorts = session.connectPorts;

			canvas.init();
		}

		// toolbar binding

		if (toolbar != null) {
			toolbar.onRequestCreateScene = session.createScene;
			toolbar.onRequestSwitchScene = session.switchScene;
			toolbar.onRequestDuplicateScene = session.duplicateScene;
			toolbar.onRequestDeleteScene = session.deleteScene;
			toolbar.onRequestSaveScene = session.saveScene;
			toolbar.onRequestExportScene = session.exportScene;
			toolbar.onRequestOpenScene = session.loadScene;
			toolbar.duplicateScene = (s) -> {
				session.workspace.scenes.exists(s);
			}

			toolbar.onRequestGetActiveScene = session.getActiveScene;
			toolbar.onRequestGetWorkspaceScenes = session.getWorkspaceScenes;
			toolbar.onRequestRenameScene = session.renameScene;

			toolbar.onRequestCreateWorkspace = session.createWorkspace;
			toolbar.onRequestGetWorkspaceName = session.getWorkspaceName;
			toolbar.onRequestRenameWorkspace = session.renameWorkspace;
			toolbar.onRequestSaveWorkspace = session.saveWorkspace;
			toolbar.onRequestSaveAsWorkspace = session.saveAsWorkspace;
			toolbar.onRequestExportWorkspace = session.exportWorkspace;
			toolbar.onRequestOpenWorkspace = session.loadWorkspace;

			toolbar.init();
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
			palette.onRequestSchemaCreate = (s) -> {
				session.addSchemaToWorkspace(s);
			}

			palette.onRequestSceneCreate = (id) -> {
				session.createScene(id);
			}

			palette.onRequestSceneSelect = (id) -> {
				session.switchScene(id);
			}

			palette.onRequestSchemaMode = () -> {
				session.enterSchemaEditMode();
			}

			palette.init();
		}
	}
}
