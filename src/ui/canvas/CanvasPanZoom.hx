package ui.canvas;

import ui.nodes.NodeView;
import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Point;
import haxe.ui.events.MouseEvent;
import openfl.Lib;

class CanvasPanZoom {
	public var panX:Float = 0;
	public var panY:Float = 0;

	// for devensive dimension caching
	private var nodeWidthCache:Map<NodeView, Float> = new Map();
	private var nodeHeightCache:Map<NodeView, Float> = new Map();

	var canvas:NodeCanvas;
	var panning = false;
	var lastPan:Point;

	// timer to track zoom completion
	private var zoomDebounceId:Null<Int> = null;

	public function new(canvas:NodeCanvas) {
		this.canvas = canvas;
		register();
	}

	function register() {
		// TODO: for now openFL will handle middle mouse
		Lib.current.stage.addEventListener(openfl.events.MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleDown);
		Lib.current.stage.addEventListener(openfl.events.MouseEvent.MIDDLE_MOUSE_UP, onMiddleUp);

		canvas.registerEvent(MouseEvent.MOUSE_WHEEL, onWheel);
		canvas.registerEvent(MouseEvent.MOUSE_MOVE, onMove);
	}

	function onMiddleDown(e:openfl.events.MouseEvent) {
		panning = true;
		lastPan = new Point(e.stageX, e.stageY);
	}

	function onMiddleUp(_:openfl.events.MouseEvent) {
		panning = false;
	}

	function onMove(e:MouseEvent) {
		if (!panning)
			return;

		var dx = e.screenX - lastPan.x;
		var dy = e.screenY - lastPan.y;

		lastPan.x = e.screenX;
		lastPan.y = e.screenY;

		var bounds = getPanBounds();

		// X axis
		if (dx < 0 && panX <= bounds.minX)
			dx *= 0.1;
		if (dx > 0 && panX >= bounds.maxX)
			dx *= 0.1;
		if (dx > 0 && panX >= 0)
			dx = 0;

		// Y axis
		if (dy < 0 && panY <= bounds.minY)
			dy *= 0.1;
		if (dy > 0 && panY >= bounds.maxY)
			dy *= 0.1;
		if (dy > 0 && panY >= 0)
			dy = 0;

		panX += dx;
		panY += dy;

		apply(false);
	}

	function onWheel(e:MouseEvent) {
		var old = canvas.zoom;
		canvas.zoom *= (e.delta > 0) ? 1.1 : 0.9;
		canvas.zoom = Math.max(0.25, Math.min(2.5, canvas.zoom));

		if (canvas.zoom != old) {
			// soft clamp: only if zoom pushes further out
			var bounds = getPanBounds();
			panX = Math.max(bounds.minX, Math.min(bounds.maxX, panX));
			panY = Math.max(bounds.minY, Math.min(bounds.maxY, panY));

			#if js
			apply(false);
			if (zoomDebounceId != null) {
				js.Syntax.code("clearTimeout({0})", zoomDebounceId);
			}
			zoomDebounceId = js.Syntax.code("setTimeout({0}, 10)", function() {
				apply(true);
				zoomDebounceId = null;
			});
			#else
			apply();
			#end
		}
	}

	public function cullComponents() {
		if (canvas.width <= 0 || canvas.height <= 0)
			return;

		var zoom = canvas.zoom;

		// inverse transform screen boundaries back into world coordinates
		var viewLeft = -panX / zoom;
		var viewTop = -panY / zoom;
		var viewRight = (canvas.width - panX) / zoom;
		var viewBottom = (canvas.height - panY) / zoom;

		var padding = 100;
		viewLeft -= padding;
		viewTop -= padding;
		viewRight += padding;
		viewBottom += padding;

		for (node in canvas.nodes) {
			if (node.width > 0 && !node.hidden) {
				nodeWidthCache.set(node, node.width);
				nodeHeightCache.set(node, node.height);
			}

			var w = nodeWidthCache.exists(node) ? nodeWidthCache.get(node) : (node.width > 0 ? node.width : 200);
			var h = nodeHeightCache.exists(node) ? nodeHeightCache.get(node) : (node.height > 0 ? node.height : 150);

			var nodeRight = node.left + w;
			var nodeBottom = node.top + h;

			var isVisible = (nodeRight >= viewLeft && node.left <= viewRight && nodeBottom >= viewTop && node.top <= viewBottom);

			node.hidden = !isVisible;
		}

		for (c in canvas.connections) {
			var fromNode = c.fromNode;
			var toNode = c.toNode;

			var fW = nodeWidthCache.exists(fromNode) ? nodeWidthCache.get(fromNode) : 150;
			var tW = nodeWidthCache.exists(toNode) ? nodeWidthCache.get(toNode) : 150;
			var fH = nodeHeightCache.exists(fromNode) ? nodeHeightCache.get(fromNode) : 100;
			var tH = nodeHeightCache.exists(toNode) ? nodeHeightCache.get(toNode) : 100;

			// bounding area encompassing both connected endpoints
			// preserves rendering on long spanning wires even if endpoints are off-screen
			var x1 = Math.min(fromNode.left, toNode.left);
			var x2 = Math.max(fromNode.left + fW, toNode.left + tW);
			var y1 = Math.min(fromNode.top, toNode.top);
			var y2 = Math.max(fromNode.top + fH, toNode.top + tH);

			var edgeVisible = (x2 >= viewLeft && x1 <= viewRight && y2 >= viewTop && y1 <= viewBottom);
			c.hidden = !edgeVisible;
		}
	}

	function apply(forceHeavyRedraw:Bool = true) {
		var content = canvas.contentLayer;
		content.scaleX = content.scaleY = canvas.zoom;
		content.left = panX;
		content.top = panY;

		canvas.grid.offsetX = -panX;
		canvas.grid.offsetY = -panY;

		cullComponents();

		var targetLoD = ui.nodes.NodeView.NodeLoD.Full;
		if (canvas.zoom < 0.4) {
			targetLoD = ui.nodes.NodeView.NodeLoD.Minimal;
		} else if (canvas.zoom < 0.75) {
			targetLoD = ui.nodes.NodeView.NodeLoD.Compact;
		}

		for (node in canvas.nodes) {
			if (!node.hidden) {
				node.setLoD(targetLoD);
			}
		}

		if (forceHeavyRedraw) {
			#if !js
			canvas.grid.cellSize = Std.int(20 * canvas.zoom);
			#end

			canvas.refreshConnections();
			canvas.grid.drawGrid();

			if (canvas.minimap != null) {
				canvas.minimap.update();
			}
		}
	}

	// TODO: only do this based on the current bounds vs the node being dragged ( parameter ? )
	function getPanBounds():{
		minX:Float,
		maxX:Float,
		minY:Float,
		maxY:Float
	} {
		var viewportW = canvas.width;
		var viewportH = canvas.height;

		var contentW = canvas.contentBounds.width * canvas.zoom;
		var contentH = canvas.contentBounds.height * canvas.zoom;

		return {
			minX: Math.min(0, viewportW - contentW),
			maxX: 0,
			minY: Math.min(0, viewportH - contentH),
			maxY: 0
		};
	}

	public function updateContentBounds() {
		var minX = 0.0;
		var minY = 0.0;
		var maxX = 0.0;
		var maxY = 0.0;

		for (n in canvas.nodes) {
			minX = Math.min(minX, n.left);
			minY = Math.min(minY, n.top);
			maxX = Math.max(maxX, n.left + n.width);
			maxY = Math.max(maxY, n.top + n.height);
		}

		var padding = 200;

		var logicalWidth = (maxX - minX) + padding * 2;
		var logicalHeight = (maxY - minY) + padding * 2;

		#if js
		// Standard safe Max Texture Size for desktop WebGL targets
		// Use 8192.0 for safety, or 16384.0 if your users make colossal node graphs
		var MAX_DESKTOP_TEXTURE_SIZE = 8192.0;

		// Clamp the actual component size so WebGL doesn't crash and turn black
		canvas.contentLayer.width = Math.min(logicalWidth, MAX_DESKTOP_TEXTURE_SIZE);
		canvas.contentLayer.height = Math.min(logicalHeight, MAX_DESKTOP_TEXTURE_SIZE);
		#else
		canvas.contentLayer.width = logicalWidth;
		canvas.contentLayer.height = logicalHeight;
		#end

		if (canvas.contentBounds == null) {
			canvas.contentBounds = new Rectangle(0, 0, logicalWidth, logicalHeight);
		} else {
			canvas.contentBounds.width = logicalWidth;
			canvas.contentBounds.height = logicalHeight;
		}

		cullComponents();
	}

	function clampPan() {
		var viewportW = canvas.width;
		var viewportH = canvas.height;

		var contentW = canvas.contentBounds.width * canvas.zoom;
		var contentH = canvas.contentBounds.height * canvas.zoom;

		// If content is smaller than viewport, lock to 0
		var minPanX = Math.min(0, viewportW - contentW);
		var minPanY = Math.min(0, viewportH - contentH);

		panX = clamp(panX, minPanX, 0);
		panY = clamp(panY, minPanY, 0);
	}

	inline function clamp(v:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, v));
	}
}
