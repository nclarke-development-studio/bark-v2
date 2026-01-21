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

	public function new(node:NodeView, data:PortData, ?onDragEnd:(id:String) -> Void) {
		super();
		this.node = node;
		this.data = data;
		this.onDragEnd = onDragEnd;

		addClass("port");
		// percentWidth = 100;

		// optional: horizontal layout, icon + label
		// var label = new Label();
		// label.text = data.name;
		// label.addClass("port-label");
		// addComponent(label);

		// Optional: small button for adding connections interactively
		connectBtn = new Button();
		connectBtn.text = "●"; // simple connection dot
		connectBtn.addClass("port-button");
		addComponent(connectBtn);

		// enable dragging connections from this port
		connectBtn.registerEvent(MouseEvent.MOUSE_DOWN, startDragConnection);
		connectBtn.registerEvent(MouseEvent.MOUSE_UP, endDragConnection);
	}

	/** Start a new connection from this port */
	private function startDragConnection(e:MouseEvent):Void {
		e.cancel();
		NodeCanvas.instance.beginConnection(this, e);
	}

	private function endDragConnection(e:MouseEvent):Void {
		if (data.direction != PortDirection.Input)
			return;
		e.cancel();
		var result = NodeCanvas.instance.finishConnection(this);
		if (onDragEnd != null)
			onDragEnd(result);
	}

	public function center():Point {
		return connectBtn.localToGlobal(new Point(connectBtn.width / 2, connectBtn.height / 2));
	}

	/** Optional: add a connection to this port */
	public function addConnection(conn:ConnectionView):Void {
		connections.push(conn);
	}

	/** Optional: remove a connection */
	public function removeConnection(conn:ConnectionView):Void {
		connections.remove(conn);
	}
}
