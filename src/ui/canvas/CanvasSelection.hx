package ui.canvas;

import haxe.ui.events.MouseEvent;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;

class CanvasSelection {
	var canvas:NodeCanvas;

	public var selectionArea:Canvas;

	public var selecting = false;

	var start:Point;
	var end:Point;

	var lastMousePos:Point;

	public var movingSelectedNodes = false;

	// callbacks
	public var onRequestContextMenu:(c:NodeCanvas, e:MouseEvent) -> Void;

	public function new(canvas:NodeCanvas) {
		this.canvas = canvas;

		selectionArea = new Canvas();
		selectionArea.percentWidth = selectionArea.percentHeight = 100;
		selectionArea.visible = false;
		selectionArea.mouseEnabled = false;

		selectionArea.onRightClick = function(e:MouseEvent) {
			e.cancel();
			if (onRequestContextMenu != null) {
				onRequestContextMenu(canvas, e);
			}
		}
	}

	public function beginSelection(x:Float, y:Float) {
		selecting = true;
		start = new Point(x, y);
		end = new Point(x, y);

		var g = selectionArea.componentGraphics;
		g.clear();

		selectionArea.visible = true;
	}

	public function update(x:Float, y:Float) {
		if (!selecting)
			return;
		end.x = x;
		end.y = y;
		updateHits(start.x, start.y, x, y);
		drawSelectionRect();
	}

	public function endSelection() {
		selecting = false;

		if (canvas.selectedNodes.length < 2) {
			end = null;
			start = null;
			selectionArea.visible = false;
		}
	}

	function updateHits(x1:Float, y1:Float, x2:Float, y2:Float) {
		canvas.clearSelection();

		var sx = Math.min(x1, x2);
		var sy = Math.min(y1, y2);
		var ex = Math.max(x1, x2);
		var ey = Math.max(y1, y2);

		for (n in canvas.nodes) {
			var fullyInside = n.left >= sx && n.top >= sy && (n.left + n.width) <= ex && (n.top + n.height) <= ey;

			if (fullyInside) {
				canvas.selectNode(n);
			} else {
				canvas.deselectNode(n);
			}
		}
	}

	public function drawSelectionRect():Void {
		if (start == null || end == null)
			return;

		var g = selectionArea.componentGraphics;
		g.clear();

		var x = Math.min(start.x, end.x);
		var y = Math.min(start.y, end.y);
		var w = Math.abs(end.x - start.x);
		var h = Math.abs(end.y - start.y);

		g.strokeStyle(0x66AAFF, 1, 1);
		g.fillStyle(0x66AAFF, 0.15);
		g.rectangle(x, y, w, h);
	}

	// movement
	public function beginMove(startX:Float, startY:Float) {
		movingSelectedNodes = true;
		lastMousePos = new Point(startX, startY);
	}

	// Inside CanvasSelection.hx

	public function updateMove(currentX:Float, currentY:Float) {
		if (!movingSelectedNodes)
			return;

		var dx = currentX - lastMousePos.x;
		var dy = currentY - lastMousePos.y;

		if (dx == 0 && dy == 0)
			return;

		for (node in canvas.selectedNodes) {
			// Update View
			node.left += dx;
			node.top += dy;

			node.data.x = node.left;
			node.data.y = node.top;

			canvas.refreshConnections(node);
		}

		if (start != null && end != null) {
			start.x += dx;
			start.y += dy;
			end.x += dx;
			end.y += dy;

			drawSelectionRect();
		}

		// Update trackers
		lastMousePos.x = currentX;
		lastMousePos.y = currentY;

		// Update the global canvas bounds (for minimap/scrollbars)
		canvas.updateContentBounds();
	}

	public function endMove() {
		movingSelectedNodes = false;
		lastMousePos = null;
	}
}
