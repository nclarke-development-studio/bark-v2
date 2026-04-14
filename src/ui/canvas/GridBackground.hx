package ui.canvas;

import haxe.ui.graphics.ComponentGraphics;
import openfl.display.Graphics;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;
import haxe.ui.events.MouseEvent;

class GridBackground extends Canvas {
	public var cellSize:Int = 20;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	// public var lineColor:Int = 0xAAAAAA;
	public var lineColor:Int = 0x000000;

	private var _downPos:Point = null;

	public function new() {
		super();
		percentWidth = 100;
		percentHeight = 100;
		mouseEnabled = false;
		backgroundColor = 0xffffff;
		mouseEnabled = false;
		alpha = 0.2;
	}

	override function onResized() {
		super.onResized();
		drawGrid();
	}

	public function drawGrid():Void {
		var g = componentGraphics;
		g.clear();
		g.strokeStyle(1, lineColor, alpha);

		var w = width;
		var h = height;

		var startX = offsetX % cellSize;
		var startY = offsetY % cellSize;

		if (startX < 0)
			startX += cellSize;
		if (startY < 0)
			startY += cellSize;

		var x = -startX;
		while (x < w) {
			g.moveTo(x, 0);
			g.lineTo(x, h);
			x += cellSize;
		}

		var y = -startY;
		while (y < h) {
			g.moveTo(0, y);
			g.lineTo(w, y);
			y += cellSize;
		}
	}

	@:bind(this, MouseEvent.MOUSE_DOWN)
	private function onCanvasMouseDown(event:MouseEvent) {
		_downPos = new Point(event.localX, event.localY);
		componentGraphics.moveTo(_downPos.x, _downPos.y);
	}

	@:bind(this, MouseEvent.MOUSE_MOVE)
	private function onCanvasMouseMove(event:MouseEvent) {
		if (_downPos == null) {
			return;
		}
		componentGraphics.lineTo(event.localX, event.localY);
		_downPos = new Point(event.localX, event.localY);
	}

	@:bind(this, MouseEvent.MOUSE_UP)
	private function onCanvasMouseUp(event:MouseEvent) {
		_downPos = null;
	}
}
