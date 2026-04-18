package ui.connectionEditor;

import haxe.Timer;
import ui.nodeeditor.NodeEditor;
import ui.connections.ConnectionDataEditor;
import data.ConnectionData;
import haxe.ui.components.Button;
import ui.nodes.NodeDataEditor;
import util.ConnectionHelpers;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.containers.dialogs.Dialog;
import ui.canvas.NodeCanvas;
import ui.nodes.NodeView;

class ConnectionEditor extends Dialog {
	var canvas:NodeCanvas;
	var focused:ConnectionData;

	var leftCol:VBox;
	var centerCol:VBox;
	var rightCol:VBox;

	public function new(canvas:NodeCanvas, focused:ConnectionData) {
		super();
		this.canvas = canvas;
		this.focused = focused;

		title = 'Edge: ${focused.id}';

		percentWidth = percentHeight = 80;

		var root = new HBox();
		root.percentWidth = root.percentHeight = 100;

		leftCol = createColumn("From");
		centerCol = createColumn("Edge");
		rightCol = createColumn("To");

		root.addComponent(leftCol);
		root.addComponent(centerCol);
		root.addComponent(rightCol);

		addComponent(root);

		rebuild();
	}

	function createColumn(title:String):VBox {
		var v = new VBox();
		v.percentWidth = 33;
		v.percentHeight = 100;
		v.padding = 8;

		var lbl = new Label();
		lbl.text = title;
		lbl.addClass("column-header");
		v.addComponent(lbl);

		return v;
	}

	function rebuild():Void {
		leftCol.removeAllComponents();
		centerCol.removeAllComponents();
		rightCol.removeAllComponents();

		var leftLabel = new Label();
		leftLabel.text = "From";

		var centerLabel = new Label();
		centerLabel.text = "Edge";

		var rightLabel = new Label();
		rightLabel.text = "To";

		leftCol.addComponent(leftLabel);
		centerCol.addComponent(centerLabel);
		rightCol.addComponent(rightLabel);

		populateIncoming();
		populateCenter();
		populateOutgoing();
	}

	function populateIncoming():Void {
		var nodes = canvas.nodes.filter(n -> n.data.id == focused.fromNode);

		for (n in nodes) {
			leftCol.addComponent(makeNavItem(n));
		}
	}

	function populateCenter():Void {
		var editor = new ConnectionDataEditor(focused);
		editor.percentWidth = 100;
		centerCol.addComponent(editor);
	}

	function populateOutgoing():Void {
		var nodes = canvas.nodes.filter(n -> n.data.id == focused.toNode);

		for (n in nodes) {
			rightCol.addComponent(makeNavItem(n));
		}
	}

	function makeNavItem(node:NodeView):Button {
		var lbl = new Button();
		lbl.text = node.data.type;
		lbl.addClass("node-link");

		lbl.onClick = _ -> {
			var dialog = new NodeEditor(canvas, node);
			dialog.showDialog();
			Timer.delay(() -> {
				this.disposeComponent();
			}, 100);
		};

		return lbl;
	}
}
