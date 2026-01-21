package ui.canvas;

import ui.menus.SelectionRectContextMenu;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;
import ui.nodes.NodeView;

class CanvasSelection {
	var canvas:NodeCanvas;

	public var selectionArea:Canvas;

	public var selecting = false;

	var start:Point;
	var end:Point;

	public function new(canvas:NodeCanvas) {
		this.canvas = canvas;

		selectionArea = new Canvas();
		selectionArea.percentWidth = selectionArea.percentHeight = 100;
		// selectionArea.mouseEnabled = false;

		selectionArea.onRightClick = function(e:MouseEvent) {
			e.cancel();

			var menu = new SelectionRectContextMenu(canvas, canvas.controller);
			menu.left = e.screenX;
			menu.top = e.screenY;
			menu.show();
		}
	}

	public function beginSelection(x:Float, y:Float) {
		selecting = true;
		start = new Point(x, y);
		end = new Point(x, y);

		var g = selectionArea.componentGraphics;
		g.clear();

		if (!canvas.contentLayer.containsComponent(selectionArea)) {
			canvas.contentLayer.addComponent(selectionArea);
		}
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
		end = null;
		start = null;

		if (canvas.selectedNodes.length == 0 && canvas.contentLayer.containsComponent(selectionArea)) {
			canvas.contentLayer.removeComponent(selectionArea);
		}
	}

	// function updateHits(x1:Float, y1:Float, x2:Float, y2:Float) {
	// 	canvas.clearSelection();
	// 	var sx = Math.min(x1, x2);
	// 	var sy = Math.min(y1, y2);
	// 	var ex = Math.max(x1, x2);
	// 	var ey = Math.max(y1, y2);
	// 	var invScale = 1.0 / canvas.contentLayer.scaleX;
	// 	var offsetX = -canvas.contentLayer.left;
	// 	var offsetY = -canvas.contentLayer.top;
	// 	sx = (sx + offsetX) * invScale;
	// 	sy = (sy + offsetY) * invScale;
	// 	ex = (ex + offsetX) * invScale;
	// 	ey = (ey + offsetY) * invScale;
	// 	// TODO: optimize this
	// 	for (n in canvas.nodes) {
	// 		if (n.left < ex && n.left + n.width > sx && n.top < ey && n.top + n.height > sy) {
	// 			canvas.selectNode(n);
	// 		} else {
	// 			canvas.deselectNode(n);
	// 		}
	// 	}
	// }

	function updateHits(x1:Float, y1:Float, x2:Float, y2:Float) {
		canvas.clearSelection();

		var sx = Math.min(x1, x2);
		var sy = Math.min(y1, y2);
		var ex = Math.max(x1, x2);
		var ey = Math.max(y1, y2);

		// var invScale = 1.0 / canvas.contentLayer.scaleX;
		// var offsetX = -canvas.contentLayer.left;
		// var offsetY = -canvas.contentLayer.top;

		// sx = (sx + offsetX) * invScale;
		// sy = (sy + offsetY) * invScale;
		// ex = (ex + offsetX) * invScale;
		// ey = (ey + offsetY) * invScale;

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
}
