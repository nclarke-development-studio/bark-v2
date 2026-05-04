package ui.connections;

import ui.canvas.NodeCanvas;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.Button;
import haxe.ui.geom.Point;
import haxe.ui.components.Canvas;
import ui.nodes.NodeView;
import data.ConnectionData;

class ConnectionView extends Canvas {
	public var fromNode:NodeView;
	public var toNode:NodeView;
	public var data:ConnectionData;

	// Cached Bezier points
	private var sx:Float;
	private var sy:Float;
	private var ex:Float;
	private var ey:Float;
	private var c1x:Float;
	private var c1y:Float;
	private var c2x:Float;
	private var c2y:Float;

	var midButton:Button;

	public var onRequestContextMenu:(c:ConnectionData) -> Void;

	public function new(fromNode:NodeView, toNode:NodeView, data:ConnectionData) {
		super();
		this.fromNode = fromNode;
		this.toNode = toNode;
		this.data = data;

		left = 0;
		top = 0;

		midButton = new Button();
		midButton.text = "X";
		midButton.width = 20;
		midButton.height = 20;

		midButton.onClick = function(_) {
			fromNode.removeConnection(data);
		};

		midButton.onRightClick = e -> {
			e.cancel();
			if(onRequestContextMenu != null){
				onRequestContextMenu(this.data);
			}
		}

		addComponent(midButton);
	}

	// Unique key for lookup in canvas maps
	public function dataKey():String {
		return data.id;
	}

	public function updateBezier(c:NodeCanvas):Void {
		redraw(c);
	}

	private function redraw(c:NodeCanvas):Void {
		graphics.clear();

		var fromPos = c.contentLayer.globalToLocal(fromNode.getPortPosition(data.fromPort));
		var toPos = c.contentLayer.globalToLocal(toNode.getPortPosition(data.toPort));

		sx = fromPos.x;
		sy = fromPos.y;
		ex = toPos.x;
		ey = toPos.y;

		var dx = (ex - sx) * 0.5;
		c1x = sx + dx;
		c1y = sy;
		c2x = ex - dx;
		c2y = ey;

		graphics.lineStyle(2, 0x00E1FF, 1);
		graphics.moveTo(sx, sy);
		graphics.cubicCurveTo(c1x, c1y, c2x, c2y, ex, ey);
		graphics.endFill();

		// update mid-button relative to the Canvas
		if (midButton != null) {
			var midpoint = getMidPoint();

			midButton.x = midpoint.x - midButton.width / 2;
			midButton.y = midpoint.y - midButton.height / 2;
		}
	}

	private function getMidPoint():Point {
		var t = 0.5;
		var mt = 1 - t;

		var x = mt * mt * mt * sx + 3 * mt * mt * t * c1x + 3 * mt * t * t * c2x + t * t * t * ex;

		var y = mt * mt * mt * sy + 3 * mt * mt * t * c1y + 3 * mt * t * t * c2y + t * t * t * ey;

		return new Point(x, y);
	}
}
