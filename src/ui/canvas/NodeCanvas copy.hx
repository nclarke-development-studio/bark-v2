package ui.canvas;

import util.DragUtil;
import data.PortData.PortDirection;
import openfl.Lib;
import haxe.ui.geom.Rectangle;
import util.ArrayUtils;
import haxe.ds.StringMap;
import ui.menus.GraphContextMenu;
import haxe.ui.geom.Point;
import haxe.ui.containers.Absolute;
import haxe.ui.components.Canvas;
import haxe.ui.events.MouseEvent;
import ui.nodes.NodeView;
import ui.nodes.PortView;
import ui.connections.ConnectionView;

/*

	[ Window ]
	└── NodeCanvas (viewport)
		├── GridBackground is drawn fixed
		├── contentLayer (world + nodes + connections) can grow arbitrarily large
		    └── nodeLayer
		    └── edgeLayer

 */
class NodeCanvas extends Absolute {
	public static var instance:NodeCanvas;

	// ========================
	// Graph visuals
	// ========================
	public var nodes:Array<NodeView> = [];
	public var connections:Array<ConnectionView> = [];

	// Maps for fast edge lookup
	private var edgesIntoMap:Map<String, Array<ConnectionView>>;
	private var edgesOutMap:Map<String, Array<ConnectionView>>;

	// ========================
	// Selection
	// ========================
	public var selectedNodes:Array<NodeView> = [];

	var selectionRect:Canvas;
	var selecting:Bool = false;
	var selStart:Point;

	// ========================
	// Pan / Zoom
	// ========================
	public var zoom:Float = 1.0;

	var panX:Float = 0;
	var panY:Float = 0;
	var panning:Bool = false;
	var lastPan:Point;

	// ========================
	// Connection preview
	// ========================
	var pendingPort:PortView;
	var previewCable:Canvas;

	var grid:GridBackground;
	var contentLayer:Absolute;
	var edgeLayer:Absolute;
	var nodeLayer:Absolute;
	var contentBounds:Rectangle;

	public var controller:EditorController;

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

		previewCable = new Canvas();
		previewCable.percentWidth = previewCable.percentHeight = 100;
		previewCable.mouseEnabled = false;

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

		for (node in nodes)
			nodeLayer.addComponent(node);

		for (connection in connections)
			edgeLayer.addComponent(connection);

		registerMouseEvents();
		updateContentBounds();
	}

	override function onResized() {
		invalidate();
		super.onResized();
		if (grid != null) {
			grid.drawGrid();
		}
	}

	// ======================================================
	// Mouse handling
	// ======================================================

	function registerMouseEvents() {
		// onMouseDown = onDown;
		// onMouseMove = onMove;
		// onMouseUp = onUp;
		// onMouseWheel = onWheel;

		registerEvent(MouseEvent.RIGHT_CLICK, e -> {
			if (controller != null) {
				var menu = new GraphContextMenu(this, controller);
				menu.left = e.localX;
				menu.top = e.localY;
				menu.show();
			}
		});

		// grid.registerEvent(MouseEvent.MOUSE_OUT, onMouseLeaveCanvas);

		// TODO: for now openFL will handle middle mouse
		Lib.current.stage.addEventListener(openfl.events.MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleDown);
		Lib.current.stage.addEventListener(openfl.events.MouseEvent.MIDDLE_MOUSE_UP, onMiddleUp);
		Lib.current.stage.addEventListener(openfl.events.MouseEvent.MOUSE_OUT, onMouseLeaveCanvas);

		// Screen.instance.registerEvent(MouseEvent.MOUSE_OUT, onMouseLeaveCanvas);
		// registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
		// registerEvent(MouseEvent.MOUSE_UP, onMouseUp);
		// registerEvent(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleDown);
		// registerEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
		// registerEvent(MouseEvent.MIDDLE_MOUSE_UP, onMiddleUp);
		// registerEvent(MouseEvent.MOUSE_WHEEL, onWheel);
	}

	@:bind(this, MouseEvent.MOUSE_DOWN)
	function onMouseDown(e:MouseEvent) {
		beginSelection();
	}

	// @:bind(this, MouseEvent.RIGHT_MOUSE_DOWN)
	function onMiddleDown(e:openfl.events.MouseEvent) {
		panning = true;
		lastPan = new Point(e.localX, e.localY);
		return;
	}

	@:bind(this, MouseEvent.MOUSE_MOVE)
	function onMouseMove(e:MouseEvent) {
		// Pan
		if (panning) {
			panX += e.screenX - lastPan.x;
			panY += e.screenY - lastPan.y;

			// Clamp so content never goes below (0,0)
			panX = Math.min(0, panX);
			panY = Math.min(0, panY);

			lastPan.x = e.screenX;
			lastPan.y = e.screenY;

			applyTransform();
			return;
		}

		// Selection drag
		if (selecting) {
			updateSelection(mouseX, mouseY);
		}

		// Connection preview
		if (pendingPort != null && previewCable != null) {
			// previewCable.invalidate();
			drawPreviewCable();
		}
	}

	@:bind(this, MouseEvent.MOUSE_UP)
	function onMouseUp(_:MouseEvent) {
		if (selecting) {
			endSelection();
		}
		if (pendingPort != null) {
			cancelPreview();
			previewCable.invalidate();
		}
	}

	// @:bind(this, MouseEvent.RIGHT_MOUSE_UP)
	function onMiddleUp(_:openfl.events.MouseEvent) {
		panning = false;
	}

	@:bind(this, MouseEvent.MOUSE_WHEEL)
	function onWheel(e:MouseEvent) {
		var oldZoom = zoom;
		zoom *= (e.delta > 0) ? 1.1 : 0.9;
		zoom = Math.max(0.25, Math.min(2.5, zoom));

		if (zoom != oldZoom) {
			applyTransform();
		}
	}

	// function onMouseLeaveCanvas(e:MouseEvent) {
	function onMouseLeaveCanvas(e:openfl.events.MouseEvent) {
		// trace('mouse left');
		panning = false;
		selecting = false;
		// TODO: figure out how to trigger onMouseLeave only once
		// the mouse is outside of the canvas bounds, not on sub-elements
		// cancelPreview();
	}

	// ======================================================
	// Pan / Zoom
	// ======================================================

	function applyTransform() {
		contentLayer.scaleX = contentLayer.scaleY = zoom;
		contentLayer.left = panX;
		contentLayer.top = panY;

		grid.cellSize = Std.int(20 * zoom);

		grid.offsetX = -panX;
		grid.offsetY = -panY;

		refreshConnections();
		grid.drawGrid();
	}

	// ======================================================
	// Selection
	// ======================================================

	function beginSelection() {
		selecting = true;
		selStart = new Point(mouseX, mouseY);

		selectionRect = new Canvas();
		selectionRect.percentWidth = 100;
		selectionRect.percentHeight = 100;
		addComponent(selectionRect);
	}

	function updateSelection(x:Float, y:Float) {
		// TODO: Figure out onDraw
		// selectionRect.onDraw = g -> {
		// 	g.clear();
		// 	var rx = Math.min(selStart.x, x);
		// 	var ry = Math.min(selStart.y, y);
		// 	var rw = Math.abs(x - selStart.x);
		// 	var rh = Math.abs(y - selStart.y);

		// 	g.lineStyle(1, 0x66aaff);
		// 	g.beginFill(0x66aaff, 0.15);
		// 	g.drawRect(rx, ry, rw, rh);
		// 	g.endFill();
		// };
		selectionRect.invalidate();

		updateSelectionHits(selStart.x, selStart.y, x, y);
	}

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

	function endSelection() {
		selecting = false;
		if (selectionRect != null) {
			removeComponent(selectionRect);
			selectionRect = null;
		}
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
	// Connections
	// ======================================================

	public function beginConnection(p:PortView) {
		if (p.data.direction != PortDirection.Output)
			return;

		pendingPort = p;

		// TODO: fix this draw
		addComponent(previewCable);
		drawPreviewCable();
	}

	public function finishConnection(to:PortView) {
		if (pendingPort != null && to != pendingPort) {
			var cData = {
				fromNode: pendingPort.node.data.id,
				toNode: to.node.data.id,
				fromPort: pendingPort.data.id,
				toPort: to.data.id,
			};
			controller.connectPorts(pendingPort.node.data, pendingPort.data, to.node.data, to.data);
			// var c = new ConnectionView(pendingPort.node, to.node, cData);
			// connections.push(c);
			// addComponent(c);
		}
		cancelPreview();
	}

	function cancelPreview() {
		if (pendingPort != null) {
			removeComponent(previewCable);
			// previewCable = null;
		}
		pendingPort = null;
	}

	function drawPreviewCable() {
		if (pendingPort == null || previewCable == null)
			return;

		var g = previewCable.componentGraphics;
		g.clear();
		var p1 = pendingPort.center();
		var p2 = new Point(mouseX, mouseY);
		var dx = Math.abs(p2.x - p1.x) * 0.5;

		g.strokeStyle(0x888888, 1, 1);
		g.moveTo(p1.x, p1.y);
		// g.lineTo(p2.x, p2.y);
		g.cubicCurveTo(p1.x + dx, p1.y, p2.x - dx, p2.y, p2.x, p2.y);
	}

	// ======================================================
	// CONNECTION HELPERS
	// ======================================================

	/** All edges coming into a node */
	public function getEdgesInto(node:NodeView):Array<ConnectionView> {
		return edgesIntoMap.exists(node.data.id) ? edgesIntoMap[node.data.id] : [];
	}

	/** All edges going out of a node */
	public function getEdgesOut(node:NodeView):Array<ConnectionView> {
		return edgesOutMap.exists(node.data.id) ? edgesOutMap[node.data.id] : [];
	}

	public function refreshConnections(node:NodeView = null) {
		if (node == null) {
			for (c in connections)
				c.updateBezier();
		} else {
			for (c in getEdgesInto(node))
				c.updateBezier();
			for (c in getEdgesOut(node))
				c.updateBezier();
		}
	}

	// ======================================================
	// REBUILD UI (incremental)
	// ======================================================

	function syncNodes() {
		var dataNodeMap = new StringMap<Bool>();
		for (nd in controller.graph.data.nodes) {
			dataNodeMap.set(nd.id, true);
		}

		// remove deleted nodeViews
		var i = nodes.length - 1;
		while (i >= 0) {
			var nv = nodes[i];
			if (!dataNodeMap.exists(nv.data.id)) {
				nodeLayer.removeComponent(nv);
				nodes.splice(i, 1);
			}
			i--;
		}

		// map remaining for reuse
		var viewMap = new StringMap<NodeView>();
		for (nv in nodes) {
			viewMap.set(nv.data.id, nv);
		}

		// update nodeViews
		for (nodeData in controller.graph.data.nodes) {
			var nv = viewMap.exists(nodeData.id) ? viewMap.get(nodeData.id) : null;

			if (nv == null) {
				nv = new NodeView(nodeData, controller);

				// DragManager.instance.registerDraggable(nv, {
				// 	dragBounds: contentBounds
				// });

				DragUtil.makeScaleAwareDraggable(nv, () -> zoom, contentBounds, function(x, y) {
					nv.data.x = x;
					nv.data.y = y;
					refreshConnections(nv);
					updateContentBounds();
				});

				// TODO: figure out how to get rid of editor error here, this works but editor doesn't like this
				// nv.onDrag = function(e:DragEvent) {
				// 	nv.data.x = nv.left;
				// 	nv.data.y = nv.top;
				// 	updateContentBounds();
				// 	refreshConnections(nv);
				// };

				nodes.push(nv);
				nodeLayer.addComponent(nv);
			}

			nv.left = nodeData.x;
			nv.top = nodeData.y;
			nv.updatePorts();
		}
	}

	function syncConnections() {
		// reset edge maps
		edgesIntoMap = new Map();
		edgesOutMap = new Map();

		// Map existing ConnectionViews
		var viewMap = new StringMap<ConnectionView>();
		for (cv in connections) {
			viewMap.set(cv.dataKey(), cv);
		}

		// track valid connections
		var validKeys = new StringMap<Bool>();

		for (connData in controller.graph.data.connections) {
			var key = connData.fromPort + "->" + connData.toPort;
			validKeys.set(key, true);

			var cv = viewMap.exists(key) ? viewMap.get(key) : null;

			if (cv == null) {
				var fromNode = ArrayUtils.find(nodes, n -> n.hasPort(connData.fromPort));
				var toNode = ArrayUtils.find(nodes, n -> n.hasPort(connData.toPort));

				if (fromNode != null && toNode != null) {
					cv = new ConnectionView(fromNode, toNode, connData);
					connections.push(cv);
					edgeLayer.addComponent(cv);
				}
			}

			if (cv != null) {
				// register edges
				if (!edgesOutMap.exists(cv.fromNode.data.id))
					edgesOutMap[cv.fromNode.data.id] = [];
				edgesOutMap[cv.fromNode.data.id].push(cv);

				if (!edgesIntoMap.exists(cv.toNode.data.id))
					edgesIntoMap[cv.toNode.data.id] = [];
				edgesIntoMap[cv.toNode.data.id].push(cv);
			}
		}

		// remove deleted connection views
		var i = connections.length - 1;
		while (i >= 0) {
			var cv = connections[i];
			if (!validKeys.exists(cv.dataKey())) {
				edgeLayer.removeComponent(cv);
				connections.splice(i, 1);
			}
			i--;
		}

		refreshConnections();
	}

	function cleanupSelection() {
		var validNodeIds = new StringMap<Bool>();
		for (n in nodes) {
			validNodeIds.set(n.data.id, true);
		}

		var i = selectedNodes.length - 1;
		while (i >= 0) {
			var n = selectedNodes[i];
			if (!validNodeIds.exists(n.data.id)) {
				n.setSelected(false);
				selectedNodes.splice(i, 1);
			}
			i--;
		}
	}

	public function rebuildUI() {
		syncNodes();
		syncConnections();
		cleanupSelection();
		updateContentBounds();
	}

	// ======================================================
	// Utilities
	// ======================================================

	function hitEmptySpace(e:MouseEvent):Bool {
		return e.target == this;
	}

	// TODO: only do this based on the current bounds vs the node being dragged ( parameter ? )
	function updateContentBounds() {
		var minX = 0.0;
		var minY = 0.0;
		var maxX = 0.0;
		var maxY = 0.0;

		for (n in nodes) {
			minX = Math.min(minX, n.left);
			minY = Math.min(minY, n.top);
			maxX = Math.max(maxX, n.left + n.width);
			maxY = Math.max(maxY, n.top + n.height);
		}

		var padding = 200;

		contentLayer.width = (maxX - minX) + padding * 2;
		contentLayer.height = (maxY - minY) + padding * 2;

		// TODO: get this fixed
		// contentBounds = new Rectangle(0, 0, contentLayer.width, contentLayer.height);
		if (contentBounds == null) {
			contentBounds = new Rectangle(0, 0, contentLayer.width, contentLayer.height);
		} else {
			contentBounds.width = contentLayer.width;
			contentBounds.height = contentLayer.height;
		}
	}
}
