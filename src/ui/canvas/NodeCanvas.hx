package ui.canvas;

import haxe.ui.core.Screen;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import util.KeyCodes;
import haxe.ui.focus.FocusManager;
import haxe.ui.events.KeyboardEvent;
import ui.canvas.MiniMap;
import data.PortData;
import data.NodeData;
import data.ConnectionData;
import core.Graph;
import util.ArrayUtils;
import openfl.geom.Point;
import util.ConnectionHelpers;
import haxe.ui.geom.Rectangle;
import haxe.ui.containers.Absolute;
import haxe.ui.events.MouseEvent;
import ui.nodes.NodeView;
import ui.nodes.PortView;
import ui.connections.ConnectionView;

/*
	[ Window ]
	└── NodeCanvas (viewport, as large as the screen)
		├── GridBackground is drawn fixed
		└── contentLayer (world + nodes + connections) can grow arbitrarily large
 */
class NodeCanvas extends Absolute {
	// ========================
	// graph visuals
	public var nodes:Array<NodeView> = [];
	public var connections:Array<ConnectionView> = [];
	public var minimap:MiniMap;

	// Maps for fast edge lookup
	public var edgesIntoMap:Map<String, Array<ConnectionView>>;
	public var edgesOutMap:Map<String, Array<ConnectionView>>;

	// ========================
	// selection
	public var selectedNodes:Array<NodeView> = [];

	public var zoom:Float = 1.0;

	// render layers ========================
	public var grid:GridBackground;
	public var contentLayer:Absolute;
	public var edgeLayer:Absolute;
	public var nodeLayer:Absolute;
	public var uiLayer:Absolute;

	public var contentBounds:Rectangle;

	// canvas helpers
	public var panZoom:CanvasPanZoom;
	public var selection:CanvasSelection;
	public var connectionPreview:CanvasConnectionPreview;
	public var graphSync:CanvasGraphSync;

	// callbacks
	public var onRequestCanvasContextMenu:(NodeCanvas, x:Float, y:Float) -> Void;
	public var onRequestNodeContextMenu:(NodeView, x:Float, y:Float) -> Void;
	public var onRequestConnectionContextMenu:(ConnectionData, x:Float, y:Float) -> Void;
	public var onRequestSelectionContextMenu:(NodeCanvas, x:Float, y:Float) -> Void;

	public var onRequestNodeCreate:(node:NodeGroupSchema, x:Float, y:Float) -> Array<NodeData>;
	public var onRequestNodesDelete:(Array<NodeView>) -> Void;

	public var onRequestUndo:() -> Void;
	public var onRequestRedo:() -> Void;
	public var onRequestSave:() -> Void;

	public var onRemoveConnection:(ConnectionData) -> Void;
	public var connectPorts:(NodeData, PortData, NodeData, PortData) -> ConnectionData;

	public function new() {
		super();

		percentWidth = 100;
		percentHeight = 100;
		backgroundColor = 0xFFFFFF;

		edgesIntoMap = new Map();
		edgesOutMap = new Map();

		grid = new GridBackground();
		grid.drawGrid();
		grid.show();
		addComponent(grid);

		contentLayer = new Absolute();
		// contentLayer.backgroundColor = 'red';
		contentLayer.borderColor = 'red';
		contentLayer.borderSize = 2;
		addComponent(contentLayer);

		edgeLayer = new Absolute();
		edgeLayer.percentWidth = edgeLayer.percentHeight = 100;
		contentLayer.addComponent(edgeLayer);

		nodeLayer = new Absolute();
		nodeLayer.percentWidth = nodeLayer.percentHeight = 100;
		contentLayer.addComponent(nodeLayer);

		uiLayer = new Absolute();
		uiLayer.percentWidth = uiLayer.percentHeight = 100;
		uiLayer.mouseEnabled = false;
		addComponent(uiLayer);

		for (node in nodes) {
			// var lastX:Float = 0;
			// var lastY:Float = 0;

			// util.DragUtil.makeScaleAwareDraggable(node, () -> zoom, contentBounds, function(x, y) {
			// 	node.data.x = x;
			// 	node.data.y = y;
			// 	refreshConnections(node);
			// 	updateContentBounds();
			// });

			nodeLayer.addComponent(node);
		}

		for (connection in connections)
			edgeLayer.addComponent(connection);

		// canvas helpers
		panZoom = new CanvasPanZoom(this);
		selection = new CanvasSelection(this);

		contentLayer.addComponent(selection.selectionArea);

		connectionPreview = new CanvasConnectionPreview(this);
		uiLayer.addComponent(connectionPreview.previewCable);
		graphSync = new CanvasGraphSync(this);

		registerMouseEvents();
		panZoom.updateContentBounds();

		minimap = new MiniMap(this);
		uiLayer.addComponent(minimap);
	}

	public function init() {
		if (onRequestSelectionContextMenu != null)
			selection.onRequestContextMenu = onRequestSelectionContextMenu;
	}

	override function onResized() {
		invalidate();
		super.onResized();
		if (grid != null) {
			grid.drawGrid();
		}

		haxe.ui.Toolkit.callLater(() -> {
			if (minimap != null) {
				minimap.fixPosition();
				minimap.update();
			}
		});
	}

	public function registerMouseEvents() {
		registerEvent(MouseEvent.RIGHT_CLICK, e -> {
			if (onRequestCanvasContextMenu != null) {
				onRequestCanvasContextMenu(this, e.screenX, e.screenY);
			}
		});

		// since absolute doesn't seem to take keyboard events
		haxe.ui.core.Screen.instance.registerEvent(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent) -> {
			// to determine if this is the active node canvas
			var top = haxe.ui.core.Screen.instance.topComponent;

			if (top != null && !top.containsComponent(this) && top != this) {
				return;
			}

			var currentFocus = FocusManager.instance.focus;

			// if something is focused, and it's a text input, ignore the shortcut unless it's a save or something
			if (currentFocus != null) {
				if (Std.isOfType(currentFocus, TextField) || Std.isOfType(currentFocus, TextArea)) {
					return;
				}
			}

			e.cancel();

			switch (e.keyCode) {
				case KeyCodes.A:
					var mouseX = Screen.instance.currentMouseX;
					var mouseY = Screen.instance.currentMouseY;
					onRequestCanvasContextMenu(this, mouseX, mouseY);

				case KeyCodes.S:
					if (e.ctrlKey) {
						if (onRequestSave != null) {
							onRequestSave();
						}
					}
				case KeyCodes.Z:
					if (e.ctrlKey) {
						if (onRequestUndo != null) {
							onRequestUndo();
						}
					}

				case KeyCodes.Y:
					if (e.ctrlKey) {
						if (onRequestRedo != null) {
							onRequestRedo();
						}
					}

				case KeyCodes.DELETE:
					onRequestNodesDelete(selectedNodes);
			}
		});
	}

	@:bind(this, MouseEvent.MOUSE_DOWN)
	function onMouseDown(e:MouseEvent) {
		var localPos = contentLayer.globalToLocal(new Point(e.screenX, e.screenY));

		if (hitEmptySpace(e)) {
			clearSelection();

			selection.beginSelection(localPos.x, localPos.y);
		}
	}

	@:bind(this, MouseEvent.MOUSE_MOVE)
	function onMouseMove(e:MouseEvent) {
		var localPos = contentLayer.globalToLocal(new Point(e.screenX, e.screenY));
		if (selection.selecting) {
			selection.update(localPos.x, localPos.y);
		} else if (selection.movingSelectedNodes) {
			selection.updateMove(localPos.x, localPos.y);
		}

		if (connectionPreview.isPreviewing()) {
			connectionPreview.drawPreviewCable();
			minimap.updateComponentDisplay();
		}
	}

	@:bind(this, MouseEvent.MOUSE_UP)
	function onMouseUp(e:MouseEvent) {
		selection.endSelection();
		selection.endMove();
		// if we're dragging, we need to create a new node at this point
		if (connectionPreview.pendingPort != null && hitEmptySpace(e)) {
			var s:NodeGroupSchema = {
				name: 'Basic Node',
				color: 'green',
				nodes: [
					{
						name: 'Basic Node',
						type: 'base',
						color: 'green',
						position: [0, 0],
						fields: [],
						ports: [
							{
								id: '0',
								name: "mainSource",
								isMain: true,
								direction: Output
							},
							{
								id: '1',
								name: "mainTarget",
								isMain: true,
								direction: Input
							}
						]
					}
				],
				edges: [],
			}
			var nds = onRequestNodeCreate(s, e.screenX, e.screenY);

			// TODO: make this more stable
			connectPorts(connectionPreview.pendingPort.node.data, connectionPreview.pendingPort.data, nds[0], nds[0].ports[1]);
		}
		cancelPreview();
	}

	public function getNodeView(id:String) {
		return ArrayUtils.find(nodes, p -> p.data.id == id);
	}

	public function nodeMouseDown(e:MouseEvent, n:NodeView) {
		var localPos = contentLayer.globalToLocal(new Point(e.screenX, e.screenY));

		if (!selectedNodes.contains(n)) {
			clearSelection();
			selectNode(n);
		}
		selection.beginMove(localPos.x, localPos.y);
	}

	public function selectNode(n:NodeView) {
		if (!selectedNodes.contains(n)) {
			selectedNodes.push(n);
			n.setSelected(true);
		}
	}

	public function deselectNode(n:NodeView) {
		if (selectedNodes.contains(n)) {
			selectedNodes.remove(n);
			n.setSelected(false);
		}
	}

	public function clearSelection() {
		for (n in selectedNodes)
			n.setSelected(false);
		selectedNodes = [];
	}

	// ======================================================
	// connections
	// Starting a connection
	public function beginConnection(p:PortView, e:MouseEvent) {
		connectionPreview.beginConnection(p, e);
		this.setComponentIndex(minimap, this.numComponents - 1);
	}

	// Finishing a connection
	public function finishConnection(to:PortView) {
		if (to == null) {
			cancelPreview();
			return '';
		}
		return connectionPreview.finishConnection(to);
	}

	// Cancelling preview manually
	public function cancelPreview() {
		connectionPreview.cancelPreview();
	}

	public function refreshConnections(node:NodeView = null) {
		if (node == null) {
			for (c in connections)
				c.updateBezier(this);
		} else {
			for (c in ConnectionHelpers.getEdgesInto(node, edgesIntoMap))
				c.updateBezier(this);
			for (c in ConnectionHelpers.getEdgesOut(node, edgesOutMap))
				c.updateBezier(this);
		}
	}

	public function rebuild(g:Graph) {
		graphSync.rebuild(g);
	}

	function hitEmptySpace(e:MouseEvent):Bool {
		return e.target == this || e.target == contentLayer;
	}

	public function updateContentBounds() {
		panZoom.updateContentBounds();
		// defer draw so we have correct bounds
		haxe.ui.Toolkit.callLater(() -> {
			if (minimap != null) {
				this.setComponentIndex(minimap, this.numComponents - 1);
				minimap.update();
			}
		});
	}

	public function panTo(worldX:Float, worldY:Float) {
		// Center the viewport on the target world coordinates
		contentLayer.left = -(worldX * zoom) + (this.width / 2);
		contentLayer.top = -(worldY * zoom) + (this.height / 2);

		updateContentBounds();
	}
}
