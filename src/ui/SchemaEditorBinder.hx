package ui;

import ui.palette.SchemaEditorPalette;
import ui.menus.SelectionRectContextMenu;
import ui.menus.NodeContextMenu;
import ui.menus.GraphContextMenu;
import ui.toolbar.Toolbar;
import ui.canvas.NodeCanvas;
import core.EditorSession;

class SchemaEditorBinder {
	var session:EditorSession;
	var canvas:NodeCanvas;
	var palette:SchemaEditorPalette;
	var toolbar:Toolbar;

	public function new(s:EditorSession, ?c:NodeCanvas, ?p:SchemaEditorPalette) {
		session = s;
		canvas = c;
		palette = p;

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
