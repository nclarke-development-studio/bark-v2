package ui.canvas;

import openfl.geom.Point;
import util.ConnectionHelpers;
import haxe.ui.geom.Rectangle;
import ui.menus.GraphContextMenu;
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
	public static var instance:NodeCanvas;

	// ========================
	// graph visuals
	public var nodes:Array<NodeView> = [];
	public var connections:Array<ConnectionView> = [];

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

	public var contentBounds:Rectangle;

	public var controller:EditorController;

	// canvas helpers
	public var panZoom:CanvasPanZoom;
	public var selection:CanvasSelection;
	public var connectionPreview:CanvasConnectionPreview;
	public var graphSync:CanvasGraphSync;

	public function new() {
		super();
		instance = this;

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

		for (node in nodes) {
			util.DragUtil.makeScaleAwareDraggable(node, () -> zoom, contentBounds, function(x, y) {
				node.data.x = x;
				node.data.y = y;
				refreshConnections(node);
				updateContentBounds();
			});
			nodeLayer.addComponent(node);
		}

		for (connection in connections)
			edgeLayer.addComponent(connection);

		// canvas helpers
		panZoom = new CanvasPanZoom(this);
		selection = new CanvasSelection(this);
		connectionPreview = new CanvasConnectionPreview(this);
		graphSync = new CanvasGraphSync(this);

		registerMouseEvents();
		panZoom.updateContentBounds();
	}

	override function onResized() {
		invalidate();
		super.onResized();
		if (grid != null) {
			grid.drawGrid();
		}
	}

	function registerMouseEvents() {
		registerEvent(MouseEvent.RIGHT_CLICK, e -> {
			if (controller != null) {
				var menu = new GraphContextMenu(this, controller);
				menu.left = e.screenX;
				menu.top = e.screenY;
				menu.show();
			}
		});
	}

	// }
	// ======================================================
	// Selection
	// ======================================================

	function updateSelectionHits(x1:Float, y1:Float, x2:Float, y2:Float) {
		clearSelection();

		var sx = Math.min(x1, x2);
		var sy = Math.min(y1, y2);
		var ex = Math.max(x1, x2);
		var ey = Math.max(y1, y2);

		for (n in nodes) {
			if (n.left < ex && n.left + n.width > sx && n.top < ey && n.top + n.height > sy) {
				selectNode(n);
			}
		}
	}

	// mouse utils

	@:bind(this, MouseEvent.MOUSE_DOWN)
	function onMouseDown(e:MouseEvent) {
		var localPos = globalToLocal(new Point(e.screenX, e.screenY));
		selection.begin(localPos.x, localPos.y);
	}

	@:bind(this, MouseEvent.MOUSE_MOVE)
	function onMouseMove(e) {
		selection.update(mouseX, mouseY);
		if (connectionPreview.isPreviewing()) {
			connectionPreview.drawPreviewCable();
		}
	}

	@:bind(this, MouseEvent.MOUSE_UP)
	function onMouseUp(e) {
		selection.end();
		cancelPreview();
	}

	public function selectNode(n:NodeView) {
		if (!selectedNodes.contains(n)) {
			selectedNodes.push(n);
			n.setSelected(true);
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
	}

	// Finishing a connection
	public function finishConnection(to:PortView) {
		return connectionPreview.finishConnection(to);
	}

	// Cancelling preview manually
	public function cancelPreview() {
		connectionPreview.cancelPreview();
	}

	public function refreshConnections(node:NodeView = null) {
		if (node == null) {
			for (c in connections)
				c.updateBezier();
		} else {
			for (c in ConnectionHelpers.getEdgesInto(node, edgesIntoMap))
				c.updateBezier();
			for (c in ConnectionHelpers.getEdgesOut(node, edgesOutMap))
				c.updateBezier();
		}
	}

	public function rebuildUI() {
		graphSync.rebuildUI();
	}

	function hitEmptySpace(e:MouseEvent):Bool {
		return e.target == this;
	}

	public function updateContentBounds() {
		panZoom.updateContentBounds();
	}
}
