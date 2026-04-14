package ui.canvas;

import haxe.ui.components.Canvas;
import haxe.ui.containers.Absolute;
import haxe.ui.events.MouseEvent;

class MiniMap extends Absolute {
	private var _canvas:NodeCanvas;
	private var _isDragging:Bool = false;

	// dedicated canvas for the minimap content
	private var drawingLayer:Canvas;

	public function new(canvas:NodeCanvas) {
		super();
		_canvas = canvas;

		// Styling the minimap box
		this.width = 200;
		this.height = 150;
		this.left = 20;
		this.top = 20;
		// this.backgroundColor = 0x333333;
		// this.opacity = 0.8;
		this.opaqueBackground = 0xFFFFFF;
		this.borderColor = 0x666666;
		this.borderSize = 1;

		drawingLayer = new Canvas();
		drawingLayer.percentWidth = 100;
		drawingLayer.percentHeight = 100;
		drawingLayer.mouseEnabled = false;
		addComponent(drawingLayer);

		registerEvent(MouseEvent.MOUSE_DOWN, onMouseDown);
		registerEvent(MouseEvent.MOUSE_MOVE, onMouseMove);
		registerEvent(MouseEvent.MOUSE_OUT, _ -> _isDragging = false);
		registerEvent(MouseEvent.MOUSE_UP, _ -> _isDragging = false);
	}

	public function update() {
		var g = drawingLayer.componentGraphics;
		g.clear();

		var bounds = _canvas.contentBounds;

		if (bounds == null || bounds.width <= 0 || bounds.height <= 0)
			return;

		g.fillStyle(0x333333, 0.8);
		g.rectangle(0, 0, this.width, this.height);

		// scale, along w/ parent zoom level
		var scaleX = width / bounds.width;
		var scaleY = height / bounds.height;
		var scale = Math.min(scaleX, scaleY) * 0.9;

		g.fillStyle(0xAAAAAA, 1);
		for (node in _canvas.nodes) {
			var rx = (node.left - bounds.left) * scale;
			var ry = (node.top - bounds.top) * scale;
			var rw = node.width * scale * _canvas.zoom;
			var rh = node.height * scale * _canvas.zoom;
			if (rw > 0 && rh > 0)
				g.rectangle(rx, ry, rw, rh);
		}

		// Draw Viewport
		g.strokeStyle(0xFFFFFF, 1, 1);
		g.fillStyle(0xFFFFFF, 0);
		var viewX = (-_canvas.contentLayer.left / _canvas.zoom - bounds.left) * scale * _canvas.zoom;
		var viewY = (-_canvas.contentLayer.top / _canvas.zoom - bounds.top) * scale * _canvas.zoom;
		var viewW = (_canvas.width / _canvas.zoom) * scale * _canvas.zoom;
		var viewH = (_canvas.height / _canvas.zoom) * scale * _canvas.zoom;

		g.rectangle(viewX, viewY, viewW, viewH);
	}

	private function onMouseDown(e:MouseEvent) {
		_isDragging = true;
		e.cancel();
		panToMinimapPos(e.localX, e.localY);
	}

	private function onMouseMove(e:MouseEvent) {
		if (_isDragging) {
			e.cancel();
			panToMinimapPos(e.localX, e.localY);
		}
	}

	private function panToMinimapPos(mx:Float, my:Float) {
		var bounds = _canvas.contentBounds;
		var scaleX = width / bounds.width;
		var scaleY = height / bounds.height;
		var scale = Math.min(scaleX, scaleY) * 0.9 * _canvas.zoom;

		// Calculate world coordinates from minimap click
		var targetWorldX = (mx / scale) + bounds.left;
		var targetWorldY = (my / scale) + bounds.top;

		// Tell PanZoom to center here (you might need to expose a function in CanvasPanZoom)
		_canvas.panTo(targetWorldX, targetWorldY);
	}

	public function fixPosition() {
		if (_canvas == null)
			return;

		// Position it 20px from the right and 20px from the bottom
		this.left = _canvas.width - this.width - 20;
		this.top = _canvas.height - this.height - 20;
	}
}
