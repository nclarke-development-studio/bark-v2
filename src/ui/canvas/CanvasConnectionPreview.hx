package ui.canvas;

import haxe.ui.events.MouseEvent;
import data.PortData.PortDirection;
import haxe.ui.components.Canvas;
import haxe.ui.geom.Point;
import ui.nodes.PortView;

class CanvasConnectionPreview {
	private var canvas:NodeCanvas;

	public var pendingPort:PortView;

	public var previewCable:Canvas;

	public function new(canvas:NodeCanvas) {
		this.canvas = canvas;

		// create the preview cable layer
		previewCable = new Canvas();
		previewCable.percentWidth = previewCable.percentHeight = 100;
		previewCable.mouseEnabled = false;
		previewCable.visible = false;
		previewCable.backgroundColor = 0x000000;
	}

	/** Begin dragging a connection from a port */
	public function beginConnection(p:PortView, e:MouseEvent):Void {
		if (p.data.direction != PortDirection.Output)
			return;

		pendingPort = p;

		// if (!canvas.containsComponent(previewCable)) {
		// 	canvas.addComponent(previewCable);
		// }
		previewCable.visible = true;
		drawPreviewCable();
	}

	/** Finish the connection to another port */
	public function finishConnection(to:PortView):String {
		if (pendingPort == null || to == pendingPort)
			return '';

		var connectionId = canvas.connectPorts(pendingPort.node.data, pendingPort.data, to.node.data, to.data).id;
		cancelPreview();
		return connectionId;
	}

	/** Cancel the current preview */
	public function cancelPreview():Void {
		if (pendingPort != null) {
			// if (canvas.containsComponent(previewCable)) {
			// 	canvas.removeComponent(previewCable);
			// }
			previewCable.visible = false;
			pendingPort = null;
		}
	}

	public function drawPreviewCable():Void {
		if (pendingPort == null || previewCable == null)
			return;

		var g = previewCable.componentGraphics;
		g.clear();

		var portXY = pendingPort.center();
		var p1 = canvas.globalToLocal(portXY);
		var p2 = new Point(canvas.mouseX, canvas.mouseY);
		var dx = Math.abs(p2.x - p1.x) * 0.5;

		g.strokeStyle(0x888888, 1, 1);
		g.moveTo(p1.x, p1.y);
		g.cubicCurveTo(p1.x + dx, p1.y, p2.x - dx, p2.y, p2.x, p2.y);
	}

	/** Helper: check if a preview is active */
	public function isPreviewing():Bool {
		return pendingPort != null;
	}
}
