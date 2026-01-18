package ui.connections;

import openfl.geom.Point;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;
import haxe.ui.components.TextField;
import haxe.ui.events.DragEvent;

import ui.EditorController;
import ui.nodes.NodeView;
import data.PortData;

// class ConnectorView extends HBox {
// 	var dot:Box;
// 	var spacing:Int;

// 	public var node:NodeView;
// 	public var controller:EditorController;

// 	// Optional: connections directly attached to this port
// 	public var connections:Array<ConnectionView> = [];

// 	public function new(node:NodeView, data:PortData, controller:EditorController, label:String, main:Bool) {
// 		super();
// 		this.node = node;
// 		// this.data = data;
// 		this.controller = controller;
// 		spacing = 4;

// 		dot = new Box();
// 		dot.width = dot.height = 10;
// 		dot.addClass(main ? "connector-main" : "connector-sub");

// 		dot.registerEvent(DragEvent.DRAG_START, onDragStart);
// 		dot.registerEvent(DragEvent.DRAG_END, onDragEnd);

// 		addComponent(dot);

// 		var tf = new TextField();
// 		tf.text = label;
// 		addComponent(tf);
// 	}

// 	public function getAbsolutePosition():{x:Float, y:Float} {
// 		var pos = localToGlobal(0, 0);
// 		return {x: pos.x, y: pos.y};
// 	}

// 	function onDragStart(e:DragEvent):Void {
// 		NodeCanvas.instance.beginConnection(this);
// 	}

// 	function onDragEnd(e:DragEvent):Void {
// 		NodeCanvas.instance.endConnection(this);
// 	}

// 	public function center():Point {
// 		return dot.localToGlobal(new Point(5, 5));
// 	}
// }
