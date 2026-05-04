package ui.nodeeditor;

import haxe.ui.components.TextField;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.notifications.NotificationType;
import haxe.ui.components.Button;
import ui.nodes.NodeDataEditor;
import util.ConnectionHelpers;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.containers.dialogs.Dialog;
import ui.canvas.NodeCanvas;
import ui.nodes.NodeView;

using haxe.ui.animation.AnimationTools;

class NodeEditor extends Dialog {
	var canvas:NodeCanvas;
	var focused:NodeView;

	var leftCol:VBox;
	var centerCol:VBox;
	var rightCol:VBox;

	public function new(canvas:NodeCanvas, focused:NodeView) {
		super();
		this.canvas = canvas;
		this.focused = focused;

		title = 'Node: ${focused.data.id}';

		percentWidth = percentHeight = 80;

		var root = new HBox();
		root.percentWidth = root.percentHeight = 100;

		leftCol = createColumn("Incoming");
		centerCol = createColumn("Node");
		rightCol = createColumn("Outgoing");

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
		leftLabel.text = "Incoming";

		var idRow = new HBox();
		idRow.percentWidth = 100;
		idRow.addClass("node-id-container");

		var idInput = new TextField();
		idInput.text = focused.data.id;
		idInput.placeholder = "Node ID";
		idInput.disabled = true; // Locked by default
		idInput.percentWidth = 100;

		var lockBtn = new Button();
		lockBtn.text = "Unlock";
		lockBtn.onClick = _ -> {
			if (idInput.disabled) {
				idInput.disabled = false;
				lockBtn.text = "Apply";
				idInput.focus = true;
			} else {
				// Attempt to apply change
				if (idInput.text != focused.data.id && canvas.onRequestIDChange != null) {
					var success = canvas.onRequestIDChange(focused, focused.data.id, idInput.text);
					if (success) {
						idInput.disabled = true;
						lockBtn.text = "Unlock";
						// TODO: bit of a hack to get the text fields to sync
						focused.idInput.text = idInput.text;
					} else {
						idInput.shake();
						NotificationManager.instance.addNotification({
							title: "Duplicate Node ID",
							body: 'A node with the id <' + idInput.text + '> already exists',
							type: NotificationType.Error
						});
						// Reset if rejected (e.g., ID already exists)
						idInput.text = focused.data.id;
						idInput.disabled = true;
						lockBtn.text = "Unlock";
					}
				} else {
					// No change made
					idInput.disabled = true;
					lockBtn.text = "Unlock";
				}
			}
		};

		idRow.addComponent(idInput);
		idRow.addComponent(lockBtn);
		centerCol.addComponent(idRow);

		var rightLabel = new Label();
		rightLabel.text = "Outgoing";

		leftCol.addComponent(leftLabel);
		// centerCol.addComponent(centerLabel);
		rightCol.addComponent(rightLabel);

		populateIncoming();
		populateCenter();
		populateOutgoing();
	}

	function populateIncoming():Void {
		var nodes = ConnectionHelpers.getIncomingNodes(focused, canvas.edgesIntoMap);

		for (n in nodes) {
			leftCol.addComponent(makeNavItem(n));
		}
	}

	function populateCenter():Void {
		var editor = new NodeDataEditor(focused);
		editor.percentWidth = 100;
		editor.onLayoutChanged = () -> {
			// sync canvas layout
			var nv = focused;
			if (nv != null) {
				nv.rebuildFields();
				canvas.refreshConnections(nv);
			}
		};
		centerCol.addComponent(editor);
	}

	function populateOutgoing():Void {
		var nodes = ConnectionHelpers.getOutgoingNodes(focused, canvas.edgesOutMap);

		for (n in nodes) {
			rightCol.addComponent(makeNavItem(n));
		}
	}

	function makeNavItem(node:NodeView):Button {
		var lbl = new Button();
		lbl.text = node.data.id;
		lbl.addClass("node-link");

		lbl.onClick = _ -> {
			focused = node;
			title = 'Node: ${focused.data.id}';
			rebuild();
		};

		return lbl;
	}
}
