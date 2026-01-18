package ui.canvas;

import haxe.ui.components.Canvas;
import haxe.ui.graphics.ComponentGraphics;
import openfl.geom.Point;

class SelectionRect extends Canvas {
	public var start:Point;
	public var end:Point;

	public function new() {
		super();
		// percentWidth = 100;
		// percentHeight = 100;
		mouseEnabled = false;

		// TODO: figure out onDraw
		// onDraw = drawRect;
	}

	public function setPoints(start:Point, end:Point):Void {
		this.start = start;
		this.end = end;
		invalidate();
	}

	private function drawRect(g:ComponentGraphics):Void {
		if (start == null || end == null)
			return;

		g.clear();

		var x = Math.min(start.x, end.x);
		var y = Math.min(start.y, end.y);
		var w = Math.abs(end.x - start.x);
		var h = Math.abs(end.y - start.y);

		g.strokeStyle(1, 0x66AAFF, 1);
		g.fillStyle(0x66AAFF, 0.15);
		g.rectangle(x, y, w, h);
		// g.endFill();
	}
}
