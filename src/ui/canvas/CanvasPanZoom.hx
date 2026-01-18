package ui.canvas;

import haxe.ui.geom.Rectangle;
import haxe.ui.geom.Point;
import haxe.ui.events.MouseEvent;
import openfl.Lib;

class CanvasPanZoom {
	public var panX:Float = 0;
	public var panY:Float = 0;

	var canvas:NodeCanvas;
	var panning = false;
	var lastPan:Point;

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

		apply();
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
			apply();
		}
	}

	function apply() {
		var content = canvas.contentLayer;
		content.scaleX = content.scaleY = canvas.zoom;
		content.left = panX;
		content.top = panY;

		canvas.grid.cellSize = Std.int(20 * canvas.zoom);
		canvas.grid.offsetX = -panX;
		canvas.grid.offsetY = -panY;

		canvas.refreshConnections();
		canvas.grid.drawGrid();
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

		canvas.contentLayer.width = (maxX - minX) + padding * 2;
		canvas.contentLayer.height = (maxY - minY) + padding * 2;

		if (canvas.contentBounds == null) {
			canvas.contentBounds = new Rectangle(0, 0, canvas.contentLayer.width, canvas.contentLayer.height);
		} else {
			canvas.contentBounds.width = canvas.contentLayer.width;
			canvas.contentBounds.height = canvas.contentLayer.height;
		}
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
