package ui.nodes;

import haxe.ui.containers.Grid;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.components.CheckBox;
import haxe.ui.core.Component;
import haxe.ui.containers.HBox;
import data.ConnectionData;
import data.PortData.PortDirection;
import openfl.geom.Point;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.events.MouseEvent;
import haxe.ui.util.GUID.uuid;
import ui.nodes.PortView;
import data.NodeData;

// to help with null functions on create
interface NodeViewActions {
	function requestContextMenu(node:NodeView, e:MouseEvent):Void;
	function nodeClicked(node:NodeView):Void;
	function removeConnection(c:ConnectionData):Void;

	function connectionStart(p:PortView, e:MouseEvent):Void;
	function connectionFinish(p:PortView, e:MouseEvent):String;
}

class NodeView extends VBox {
	public var selected:Bool = false;
	public var data:NodeData;
	public var outgoingConnections:Array<PortView> = [];
	public var incomingConnections:Array<PortView> = [];

	public var sourcePort:PortView;
	public var targetPort:PortView;

	public var fieldContainer:VBox;

	// callbacks
	public var onRequestContextMenu:(n:NodeView, e:MouseEvent) -> Void;
	public var onRemoveConnection:(c:ConnectionData) -> Void;
	public var onNodeClicked:(n:NodeView) -> Void;

	// portview callbacks
	public var onConnectionStart:(PortView, MouseEvent) -> Void;
	public var onConnectionFinish:(PortView, MouseEvent) -> String;

	public function new(data:NodeData) {
		super();
		this.data = data;
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
	}

	public function init() {
		for (port in data.ports) {
			addPort(port.id, port.name, port.direction);
		}

		// sourcePort = addPort("mainSource", "mainSource", PortDirection.Output);
		// targetPort = addPort("mainTarget", "mainTarget", PortDirection.Input);
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
			if (onRequestContextMenu != null)
				onRequestContextMenu(this, e);
			// var menu = new NodeContextMenu(this, controller);
			// menu.left = e.screenX;
			// menu.top = e.screenY;
			// menu.show();
		});

		fieldContainer = new VBox();
		fieldContainer.percentWidth = 100;

		addFieldButtons();
		addComponent(fieldContainer);
		populateData();
	}

	private function populateData() {
		for (field in data.fields) {
			var valueInput:Component;
			var grid = new Grid();
			grid.columns = 3; // Key input | Value input | Delete button
			grid.percentWidth = 100;

			var keyInput = new TextField();
			keyInput.placeholder = "Key";
			keyInput.percentWidth = 90;
			keyInput.text = field.key;
			keyInput.onChange = _ -> field.key = keyInput.text;

			grid.addComponent(keyInput);

			switch (field.type) {
				default:
					valueInput = null;
				case "string", "number":
					var ti = new TextField();
					ti.percentWidth = 90;
					ti.placeholder = "input value";
					ti.text = field.value;
					ti.onChange = _ -> field.value = ti.text;
					valueInput = ti;

				case "text":
					var ta = new TextArea();
					ta.percentWidth = 100;
					ta.placeholder = "input value";
					ta.height = 60;
					ta.value = field.value;
					ta.onChange = _ -> field.value = ta.text;
					valueInput = ta;

				case "boolean":
					var cb = new CheckBox();
					cb.value = field.value;
					cb.onChange = _ -> field.value = cb.selected;
					valueInput = cb;
			}

			if (valueInput != null)
				grid.addComponent(valueInput);

			// Delete button
			var delBtn = new Button();
			delBtn.text = "X";
			delBtn.onClick = _ -> {
				fieldContainer.removeComponent(grid);
				for (i in 0...data.fields.length) {
					// Remove port if applicable
					// if (field.portId != null) {
					// 	removeConnection()
					// }
					if (data.fields[i] == field) {
						data.fields.splice(i, 1);
						break;
					}
				}
			}
			grid.addComponent(delBtn);

			if (field.type == 'data') {
				var portData = {
					id: field.portId,
					name: field.key,
					direction: PortDirection.Output,
					isMain: false,
				};

				valueInput = null;
				var pv = new PortView(this, portData, null, onConnectionStart, onConnectionFinish);
				grid.addComponent(pv);
			}

			fieldContainer.addComponent(grid);
		}
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
		var rowData:NodeField = {
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
			for (i in 0...data.fields.length) {
				if (data.fields[i] == rowData) {
					data.fields.splice(i, 1);
					break;
				}
			}
		}
		grid.addComponent(delBtn);

		if (type == 'data') {
			var portData = {
				id: uuid(),
				name: keyInput.text,
				direction: PortDirection.Output,
				isMain: false,
			};
			// data.ports.push(portData);
			rowData.portId = portData.id;

			valueInput = null;
			var pv = new PortView(this, portData, null, onConnectionStart, onConnectionFinish);
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
	public function addPort(id:String, name:String, ?direction:PortDirection = PortDirection.Output) {
		var portData = {
			id: id,
			name: name,
			direction: direction,
			isMain: false,
		};
		// data.ports.push(portData);
		var pv = new PortView(this, portData, null, onConnectionStart, onConnectionFinish);
		addComponent(pv);
		return pv;
	}

	public function hasPort(portId:String):Bool {
		return getPortViewRecursive(this, portId) != null;
	}

	public function removeConnection(c:ConnectionData) {
		if (onRemoveConnection != null)
			onRemoveConnection(c);
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
		// if (!selected) {
		// 	NodeCanvas.instance.selectNode(this);
		// } else {
		// 	NodeCanvas.instance.deselectNode(this);
		// }
		if (onNodeClicked != null)
			onNodeClicked(this);
	}
}
