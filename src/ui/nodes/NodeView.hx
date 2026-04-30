package ui.nodes;

import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.core.Component;
import haxe.ui.containers.*;
import haxe.ui.components.*;
import haxe.ui.util.GUID.uuid;
import openfl.geom.Point;
import data.ConnectionData;
import data.PortData.PortDirection;
import data.NodeData;
import ui.nodes.PortView;

class NodeView extends VBox {
	public var selected:Bool = false;
	public var data:NodeData;
	public var fieldContainer:VBox;

	// Callbacks
	public var onRequestContextMenu:(n:NodeView) -> Void;
	public var onRemoveConnection:(c:ConnectionData) -> Void;
	public var onRemoveConnectedEdges:(nodeView:NodeView, handleId:String) -> Void;
	public var onNodeClicked:(e:MouseEvent, n:NodeView) -> Void;
	public var onConnectionStart:(PortView, MouseEvent) -> Void;
	public var onConnectionFinish:(PortView, MouseEvent) -> String;

	public function new(data:NodeData) {
		super();
		this.data = data;
		addClass("node");
		top = data.y;
		left = data.x;

		var header = new Label();
		header.text = data.type;
		header.addClass("node-header");
		addComponent(header);
	}

	public function init() {
		for (port in data.ports) {
			addPort(port.id, port.name, port.direction, port.isMain);
		}

		registerEvent(MouseEvent.RIGHT_CLICK, e -> {
			e.cancel();
			if (onRequestContextMenu != null)
				onRequestContextMenu(this);
		});

		addFieldButtons();

		fieldContainer = new VBox();
		fieldContainer.percentWidth = 100;
		addComponent(fieldContainer);

		// Populate existing fields
		if (data.fields != null) {
			for (field in data.fields)
				createFieldRow(field);
		}
	}

	private function addFieldButtons():Void {
		var btnBox = new HBox();
		btnBox.continuous = true;
		btnBox.percentWidth = 100;
		addComponent(btnBox);

		var types = ["string", "text", "number", "boolean", "data"];
		for (type in types) {
			var btn = new Button();
			btn.text = "Add " + type.charAt(0).toUpperCase() + type.substring(1);
			btn.onClick = _ -> addField(type);
			btnBox.addComponent(btn);
		}
	}

	private function addField(type:String):Void {
		var rowData:NodeField = {
			type: type,
			key: "",
			value: null,
			portId: (type == "data") ? uuid() : null
		};
		if (data.fields == null)
			data.fields = [];
		data.fields.push(rowData);
		createFieldRow(rowData);
	}

	/**
	 * Refactored: Single source of truth for creating a field UI row
	 */
	private function createFieldRow(field:NodeField) {
		var grid = new Grid();
		grid.columns = 4;
		grid.percentWidth = 100;

		var keyInput = new TextField();
		keyInput.placeholder = "Key";
		keyInput.width = 100;
		keyInput.text = field.key;
		keyInput.onChange = _ -> field.key = keyInput.text;
		grid.addComponent(keyInput);

		var valueContainer = new Box();
		valueContainer.percentWidth = 100;

		var valueInput:Component = null;
		var portView:PortView = null;

		switch (field.type) {
			case "string", "number":
				var ti = new TextField();
				ti.percentWidth = 100;
				ti.text = field.value;
				ti.onChange = _ -> field.value = ti.text;
				valueInput = ti;
			case "text":
				var ta = new TextArea();
				ta.percentWidth = 100;
				ta.height = 60;
				ta.text = field.value;
				ta.onChange = _ -> field.value = ta.text;
				valueInput = ta;
			case "boolean":
				var cb = new CheckBox();
				cb.selected = field.value;
				cb.onChange = _ -> field.value = cb.selected;
				valueInput = cb;
			case "data":
				var portData = {
					id: field.portId,
					name: field.key,
					direction: PortDirection.Output,
					isMain: false,
				};
				portView = new PortView(this, portData, null, onConnectionStart, onConnectionFinish);
		}

		if (valueInput != null)
			valueContainer.addComponent(valueInput);
		grid.addComponent(valueContainer);

		var delBtn = new Button();
		delBtn.text = "X";
		delBtn.onClick = _ -> {
			fieldContainer.removeComponent(grid);
			data.fields.remove(field);
			this.validateNow();
			var cleanupId = (portView != null) ? portView.data.id : '';
			if (onRemoveConnectedEdges != null)
				onRemoveConnectedEdges(this, cleanupId);
		};
		grid.addComponent(delBtn);

		var portContainer = new Box();
		portContainer.width = 10;
		portContainer.percentHeight = 100;
		if (portView != null) {
			portView.horizontalAlign = "right";
			portView.verticalAlign = "center";

			portView.left = 10;
			portContainer.addComponent(portView);
		}
		grid.addComponent(portContainer);

		fieldContainer.addComponent(grid);
	}

	public function addPort(id:String, name:String, ?direction:PortDirection = PortDirection.Output, isMain:Bool = false) {
		var portData = {
			id: id,
			name: name,
			direction: direction,
			isMain: isMain
		};
		var pv = new PortView(this, portData, null, onConnectionStart, onConnectionFinish);

		if (isMain) {
			pv.includeInLayout = false;
			if (direction == PortDirection.Input) {
				pv.left = -pv.width / 2;
				pv.top = 10;
			} else {
				pv.registerEvent(UIEvent.READY, _ -> {
					pv.left = this.width - (pv.width / 2);
					pv.top = 10;
				});
			}
		}

		addComponent(pv);
		return pv;
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
		if (Std.isOfType(c, PortView))
			c.invalidate();
		for (child in c.childComponents)
			updatePortsRecursive(child);
	}

	public function getPortPosition(portId:String):Point {
		var pv = getPortView(portId);
		return (pv == null) ? new Point(x + width / 2, y + height / 2) : pv.center();
	}

	public function setSelected(s:Bool):Void {
		selected = s;
		if (selected)
			addClass("selected")
		else
			removeClass("selected", true);
	}

	@:bind(this, MouseEvent.MOUSE_DOWN)
	private function _onClick(e:MouseEvent):Void {
		e.cancel();
		if (onNodeClicked != null)
			onNodeClicked(e, this);
	}

	override function onResized() {
		super.onResized();
		for (child in childComponents) {
			if (Std.isOfType(child, PortView)) {
				var pv:PortView = cast child;
				if (pv.data.isMain && pv.data.direction == PortDirection.Output) {
					pv.left = this.width - (pv.width / 2);
				}
			}
		}
	}

	public function hasPort(portId:String):Bool {
		return getPortViewRecursive(this, portId) != null;
	}

	public function removeConnection(c:ConnectionData) {
		if (onRemoveConnection != null)
			onRemoveConnection(c);
	}

	public function rebuildFields():Void {
		if (fieldContainer == null)
			return;

		fieldContainer.removeAllComponents();
		populateFields();
		updatePorts(); // Refresh port positions/states
	}

	private function populateFields():Void {
		if (data.fields != null) {
			for (field in data.fields) {
				createFieldRow(field);
			}
		}
	}
}
