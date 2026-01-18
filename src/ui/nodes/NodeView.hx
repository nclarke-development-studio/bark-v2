package ui.nodes;

import haxe.ui.containers.Grid;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.components.CheckBox;
import haxe.ui.core.Component;
import haxe.ui.containers.HBox;
import data.ConnectionData;
import ui.menus.NodeContextMenu;
import data.PortData.PortDirection;
import openfl.geom.Point;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.events.MouseEvent;
import haxe.ui.util.GUID.uuid;
import ui.nodes.PortView;
import data.NodeData;

class NodeView extends VBox {
	public var selected:Bool = false;
	public var controller:EditorController;
	public var data:NodeData;
	public var outgoingConnections:Array<PortView> = [];
	public var incomingConnections:Array<PortView> = [];

	public var fieldContainer:VBox;

	public function new(data:NodeData, c:EditorController) {
		super();
		this.data = data;
		this.controller = c;
		addClass("node");
		padding = 8;
		width = 320;
		// autoWidth = true;
		top = data.y;
		left = data.x;
		var header = new Label();
		header.text = data.type;
		header.addClass("node-header");
		addComponent(header);

		addPort("source", true);
		addPort("target", true, PortDirection.Input);
		// "+" button for extra ports
		// var addBtn = new Button();
		// addBtn.text = "+";
		// addBtn.onClick = _ -> addPort("Extra", false);
		// addComponent(addBtn);
		
		// Selection click
		onClick = _onClick;
		// Context menu
		registerEvent(MouseEvent.RIGHT_CLICK, e -> {
			e.cancel();
			var menu = new NodeContextMenu(this, controller);
			menu.left = e.screenX;
			menu.top = e.screenY;
			menu.show();
		});

		fieldContainer = new VBox();
		fieldContainer.percentWidth = 100;

		addFieldButtons();
		addComponent(fieldContainer);
	}

	private function addFieldButtons():Void {
		var btnBox = new HBox();
		btnBox.continuous = true;
		btnBox.percentWidth = 100;
		addComponent(btnBox);

		var stringBtn = new Button();
		stringBtn.text = "Add String";
		stringBtn.onClick = _ -> addField("string");
		btnBox.addComponent(stringBtn);

		var textBtn = new Button();
		textBtn.text = "Add Text";
		textBtn.onClick = _ -> addField("text");
		btnBox.addComponent(textBtn);

		var numberBtn = new Button();
		numberBtn.text = "Add Number";
		numberBtn.onClick = _ -> addField("number");
		btnBox.addComponent(numberBtn);

		var boolBtn = new Button();
		boolBtn.text = "Add Boolean";
		boolBtn.onClick = _ -> addField("boolean");
		btnBox.addComponent(boolBtn);

		var dataBtn = new Button();
		dataBtn.text = "Add Data Port";
		dataBtn.onClick = _ -> addField("data");
		btnBox.addComponent(dataBtn);
	}

	private function addField(type:String):Void {
		var rowData:Dynamic = {
			type: type,
			key: "",
			value: null,
			portId: null
		};

		// Create a grid row
		var grid = new Grid();
		grid.columns = 3; // Key input | Value input | Delete button
		grid.percentWidth = 100;

		// Key input
		var keyInput = new TextField();
		keyInput.placeholder = "Key";
		keyInput.percentWidth = 90;
		keyInput.onChange = _ -> rowData.key = keyInput.text;
		grid.addComponent(keyInput);

		// Value input
		var valueInput:Component;

		switch (type) {
			default:
				valueInput = null;
			case "string", "number":
				var ti = new TextField();
				ti.percentWidth = 90;
				ti.placeholder = "input value";
				ti.onChange = _ -> rowData.value = ti.text;
				valueInput = ti;

			case "text":
				var ta = new TextArea();
				ta.percentWidth = 100;
				ta.placeholder = "input value";
				ta.height = 60;
				ta.onChange = _ -> rowData.value = ta.text;
				valueInput = ta;

			case "boolean":
				var cb = new CheckBox();
				cb.onChange = _ -> rowData.value = cb.selected;
				valueInput = cb;
		}

		if (valueInput != null)
			grid.addComponent(valueInput);

		// Delete button
		var delBtn = new Button();
		delBtn.text = "X";
		delBtn.onClick = _ -> {
			fieldContainer.removeComponent(grid);
			// Remove port if applicable
			if (rowData.portId != null) {
				for (i in 0...data.ports.length) {
					if (data.ports[i].id == rowData.portId) {
						data.ports.splice(i, 1);
						break;
					}
				}
			}
		}
		grid.addComponent(delBtn);

		if (type == 'data') {
			var portData = {
				id: uuid(),
				name: "ExtraField",
				direction: PortDirection.Output,
				isMain: false,
			};
			data.ports.push(portData);
			rowData.portId = portData.id;

			valueInput = null;
			var pv = new PortView(this, portData);
			grid.addComponent(pv);
		}

		fieldContainer.addComponent(grid);

		if (data.fields == null)
			data.fields = [];
		data.fields.push(rowData);
	}

	// -----------------------------------------------------------
	// Ports / Connectors
	// -----------------------------------------------------------
	public function addPort(name:String, main:Bool, ?direction:PortDirection = PortDirection.Output) {
		var portData = {
			id: uuid(),
			name: name,
			direction: direction,
			isMain: main,
		};
		data.ports.push(portData);
		var pv = new PortView(this, portData);
		addComponent(pv);
	}

	public function hasPort(portId:String):Bool {
		return getPortViewRecursive(this, portId) != null;
	}

	public function removeConnection(c:ConnectionData) {
		controller.removeConnection(c);
	}

	public function getPortView(portId:String):PortView {
		return getPortViewRecursive(this, portId);
	}

	private function getPortViewRecursive(c:Component, portId:String):PortView {
		if (Std.isOfType(c, PortView)) {
			var pv:PortView = cast c;
			if (pv.data.id == portId)
				return pv;
		}
		for (child in c.childComponents) {
			var found = getPortViewRecursive(child, portId);
			if (found != null)
				return found;
		}
		return null;
	}

	public function updatePorts():Void {
		updatePortsRecursive(this);
	}

	private function updatePortsRecursive(c:Component):Void {
		if (Std.isOfType(c, PortView)) {
			c.invalidate(); // or cast to PortView if needed
		}
		for (child in c.childComponents) {
			updatePortsRecursive(child);
		}
	}

	// Returns absolute canvas position of a port
	public function getPortPosition(portId:String):Point {
		var pv = getPortView(portId);
		if (pv == null)
			return new Point(x + width / 2, y + height / 2);
		return pv.center();
	}

	// haxe macro to generate this for you
	// @:bind(fn, MouseEvent.CLICK/whatever other event)
	// -----------------------------------------------------------
	// Selection
	// -----------------------------------------------------------
	public function setSelected(s:Bool):Void {
		selected = s;
		if (selected)
			addClass("selected")
		else
			removeClass("selected", true);
	}

	private function _onClick(_:haxe.ui.events.MouseEvent):Void {
		// if (!selected)
		// 	NodeCanvas.instance.selectedNodes = [];
		setSelected(!selected);
	}
}
