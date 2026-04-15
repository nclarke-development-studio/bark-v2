package ui;

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

	public function new(s:EditorSession, ?c:NodeCanvas, ?p:Palette, ?t:Toolbar) {
		session = s;
		canvas = c;
		palette = p;
		toolbar = t;

		// canvas.onRequestAddNode = (x, y) -> {
		// 	session.addNode(makeNodeAt(x, y));
		// };

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
			canvas.onRequestCanvasContextMenu = (canvas, e) -> {
				var menu = new GraphContextMenu(canvas, session);
				menu.left = e.screenX;
				menu.top = e.screenY;
				menu.show();
			};

			canvas.onRequestNodeContextMenu = (node, e) -> {
				var menu = new NodeContextMenu(node, session, canvas);
				menu.left = e.screenX;
				menu.top = e.screenY;
				menu.show();
			}

			canvas.onRequestConnectionContextMenu = (connection, e) -> {
				var menu = new ConnectionContextMenu(connection, session, canvas);
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

			toolbar.onRequestGetActiveScene = session.getActiveScene;
			toolbar.onRequestGetWorkspaceScenes = session.getWorkspaceScenes;
			toolbar.onRequestRenameScene = session.renameScene;

			toolbar.onRequestCreateWorkspace = session.createWorkspace;
			toolbar.onRequestGetWorkspaceName = session.getWorkspaceName;
			toolbar.onRequestRenameWorkspace = session.renameWorkspace;
			toolbar.onRequestSaveWorkspace = session.saveWorkspace;
			toolbar.onRequestExportWorkspace = session.saveWorkspace;
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

			palette.init();
		}
	}
}
