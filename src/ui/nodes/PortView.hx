package ui.nodes;

import haxe.ui.events.MouseEvent;
import openfl.geom.Point;
import haxe.ui.containers.HBox;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import ui.connections.ConnectionView;
import ui.canvas.NodeCanvas;
import data.PortData;

class PortView extends HBox {
	public var data:PortData;
	public var node:NodeView;

	// Optional: connections directly attached to this port
	public var connections:Array<ConnectionView> = [];

	private var connectBtn:Button;
	private var onDragEnd:(id:String) -> Void;

	public var onConnectionStart:(PortView, MouseEvent) -> Void;
	public var onConnectionFinish:(PortView, MouseEvent) -> String;

	public function new(node:NodeView, data:PortData, ?onDragEnd:(id:String) -> Void, ?oCS:(PortView, MouseEvent) -> Void,
			oCF:(PortView, MouseEvent) -> String) {
		super();
		this.node = node;
		this.data = data;

		this.onDragEnd = onDragEnd;
		onConnectionStart = oCS;
		onConnectionFinish = oCF;

		addClass("port");
		// percentWidth = 100;

		// var label = new Label();
		// label.text = data.name;
		// label.addClass("port-label");
		// addComponent(label);

		connectBtn = new Button();
		connectBtn.text = "●";
		connectBtn.addClass("port-button");
		addComponent(connectBtn);

		// enable dragging connections from this port
		connectBtn.registerEvent(MouseEvent.MOUSE_DOWN, startDragConnection);
		connectBtn.registerEvent(MouseEvent.MOUSE_UP, endDragConnection);

		mouseEnabled = true;
	}

	private function startDragConnection(e:MouseEvent):Void {
		e.cancel();
		if (onConnectionStart != null) {
			onConnectionStart(this, e);
		}
	}

	// @:bind(this, MouseEvent.MOUSE_UP)
	private function endDragConnection(e:MouseEvent):Void {
		e.cancel();
		if (data.direction != PortDirection.Input)
			return;
		var result = "";
		if (onConnectionFinish != null)
			result = onConnectionFinish(this, e);
		if (onDragEnd != null)
			onDragEnd(result);
	}

	public function center():Point {
		return connectBtn.localToGlobal(new Point(connectBtn.width / 2, connectBtn.height / 2));
	}

	public function addConnection(conn:ConnectionView):Void {
		connections.push(conn);
	}

	public function removeConnection(conn:ConnectionView):Void {
		connections.remove(conn);
	}
}
