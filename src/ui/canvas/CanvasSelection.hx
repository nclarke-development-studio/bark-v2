package ui.canvas;

import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;
import ui.nodes.NodeView;

class CanvasSelection {
	var canvas:NodeCanvas;
	var selectionRect:Canvas;
	var selecting = false;
	var start:Point;

	public function new(canvas:NodeCanvas) {
		this.canvas = canvas;
	}

	public function begin(x:Float, y:Float) {
		selecting = true;
		start = new Point(x, y);

		selectionRect = new Canvas();
		selectionRect.percentWidth = 100;
		selectionRect.percentHeight = 100;
		canvas.addComponent(selectionRect);
	}

	public function update(x:Float, y:Float) {
		if (!selecting)
			return;
		selectionRect.invalidate();
		updateHits(start.x, start.y, x, y);
	}

	public function end() {
		selecting = false;
		if (selectionRect != null) {
			canvas.removeComponent(selectionRect);
			selectionRect = null;
		}
	}

	function updateHits(x1:Float, y1:Float, x2:Float, y2:Float) {
		canvas.clearSelection();

		var sx = Math.min(x1, x2);
		var sy = Math.min(y1, y2);
		var ex = Math.max(x1, x2);
		var ey = Math.max(y1, y2);

		for (n in canvas.nodes) {
			if (n.left < ex && n.left + n.width > sx && n.top < ey && n.top + n.height > sy) {
				canvas.selectNode(n);
			}
		}
	}
}
