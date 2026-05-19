package ui.nodes;

import haxe.ui.notifications.NotificationManager;
import haxe.ui.notifications.NotificationType;
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

using haxe.ui.animation.AnimationTools;

enum NodeLoD {
	Full;
	Compact;
	Minimal;
}

class NodeView extends VBox {
	public var selected:Bool = false;
	public var data:NodeData;
	public var fieldContainer:VBox;

	var fieldButtons:HBox;

	// TODO: bit of a hack here
	public var idInput:TextField;

	private var _currentLoD:NodeLoD = Full;

	// Callbacks
	public var onRequestContextMenu:(n:NodeView) -> Void;
	public var onRemoveConnection:(c:ConnectionData) -> Void;
	public var onRequestIDChange:(node:NodeView, newId:String) -> Bool;
	public var onRemoveConnectedEdges:(nodeView:NodeView, handleId:String) -> Void;
	public var onNodeClicked:(e:MouseEvent, n:NodeView) -> Void;
	public var onConnectionStart:(PortView, MouseEvent) -> Void;
	public var onConnectionFinish:(PortView, MouseEvent) -> String;

	public function new(data:NodeData) {
		super();
		this.cacheAsBitmap = true;
		this.data = data;
		addClass("node");
		top = data.y;
		left = data.x;

		var idRow = new HBox();
		idRow.percentWidth = 100;
		idRow.addClass("node-id-container");

		idInput = new TextField();
		idInput.text = data.id;
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
				if (idInput.text != data.id && onRequestIDChange != null) {
					var success = onRequestIDChange(this, idInput.text);
					if (success) {
						idInput.disabled = true;
						lockBtn.text = "Unlock";
					} else {
						idInput.shake();
						NotificationManager.instance.addNotification({
							title: "Duplicate Node ID",
							body: 'A node with the id <' + idInput.text + '> already exists',
							type: NotificationType.Error
						});
						// Reset if rejected (e.g., ID already exists)
						idInput.text = data.id;
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
		addComponent(idRow);
		// -----------------------

		var header = new Label();
		header.text = data.type;
		header.addClass("node-header");
		addComponent(header);

		addFieldButtons();

		fieldContainer = new VBox();
		fieldContainer.percentWidth = 100;
		addComponent(fieldContainer);

		registerEvent(MouseEvent.RIGHT_CLICK, _onRightClick);
	}

	private function _onRightClick(e:MouseEvent) {
		e.cancel();
		if (onRequestContextMenu != null)
			onRequestContextMenu(this);
	}

	public function init() {
		fieldContainer.removeAllComponents();

		var i = childComponents.length - 1;
		while (i >= 0) {
			if (Std.isOfType(childComponents[i], PortView)) {
				removeComponent(childComponents[i]);
			}
			i--;
		}

		if (data.ports != null) {
			for (port in data.ports) {
				addPort(port.id, port.name, port.direction, port.isMain);
			}
		}

		if (data.fields != null) {
			for (field in data.fields) {
				createFieldRow(field);
			}
		}

		// this.validateNow();
	}

	public function refresh(newData:NodeData):Void {
		this.data = newData;

		if (idInput != null)
			idInput.text = this.data.id;

		init();
	}

	private function addFieldButtons():Void {
		fieldButtons = new HBox();
		fieldButtons.continuous = true;
		fieldButtons.percentWidth = 100;
		addComponent(fieldButtons);

		var types = ["string", "text", "number", "boolean", "data"];
		for (type in types) {
			var btn = new Button();
			btn.text = "Add " + type.charAt(0).toUpperCase() + type.substring(1);
			btn.onClick = _ -> addField(type);
			btn.registerEvent(MouseEvent.MOUSE_DOWN, (e) -> {
				e.cancel();
			});
			fieldButtons.addComponent(btn);
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
		keyInput.registerEvent(MouseEvent.MOUSE_DOWN, (e:MouseEvent) -> {
			e.cancel();
		});
		grid.addComponent(keyInput);

		var valueContainer = new Box();
		valueContainer.percentWidth = 100;

		var valueInput:Component = null;
		var portView:PortView = null;

		switch (field.type) {
			case "string", "number":
				var ti = new TextField();
				ti.registerEvent(MouseEvent.MOUSE_DOWN, (e:MouseEvent) -> {
					e.cancel();
				});
				ti.percentWidth = 100;
				ti.text = field.value;
				ti.onChange = _ -> field.value = ti.text;
				valueInput = ti;
			case "text":
				var ta = new TextArea();
				ta.registerEvent(MouseEvent.MOUSE_DOWN, (e:MouseEvent) -> {
					e.cancel();
				});
				ta.percentWidth = 100;
				ta.height = 60;
				ta.text = field.value;
				ta.onChange = _ -> field.value = ta.text;
				valueInput = ta;
			case "boolean":
				var cb = new CheckBox();
				cb.registerEvent(MouseEvent.MOUSE_DOWN, (e:MouseEvent) -> {
					e.cancel();
				});
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
			// this.validateNow();
			var cleanupId = (portView != null) ? portView.data.id : '';
			if (onRemoveConnectedEdges != null)
				onRemoveConnectedEdges(this, cleanupId);
		};
		grid.addComponent(delBtn);

		var portContainer = new Box();
		portContainer.width = 10;
		portContainer.percentHeight = 100;
		if (portView != null) {
			// portView.horizontalAlign = "right";
			// portView.verticalAlign = "center";

			// TODO: don't hardcode these somehow
			portView.includeInLayout = false;
			portView.left = 20;
			portView.top = 10 - portView.height / 2;
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
				pv.left = -5;
				pv.top = 10;
			} else {
				// if the node is already rendered (width > 0), position immediately
				if (this.width > 0) {
					// Use a default width if the port hasn't calculated its own yet
					var pw = (pv.width > 0) ? pv.width : 10;
					pv.left = this.width - (pw / 2);
					pv.top = 10;
				} else {
					// First time creation logic
					pv.registerEvent(UIEvent.READY, _ -> {
						pv.left = this.width - (pv.width / 2);
						pv.top = 10;
					});
				}
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
				if (pv.data.direction == PortDirection.Output) {
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
		updatePorts();
	}

	private function populateFields():Void {
		if (data.fields != null) {
			for (field in data.fields) {
				createFieldRow(field);
			}
		}
	}

	// LoD

	public function setLoD(lod:NodeLoD) {
		if (_currentLoD == lod)
			return; // Prevent redundant state updates
		_currentLoD = lod;

		// We disable bitmap caching while transitioning structural layouts
		this.cacheAsBitmap = false;

		switch (lod) {
			case Full:
				// Show everything
				if (childComponents[0] != null)
					childComponents[0].show(); // idRow
				fieldContainer.show();
				fieldButtons.show();
				resetPortsToDefaultLayout();

			case Compact, Minimal:
				// Hide text boxes / inner interactive fields, keep ports accessible
				if (childComponents[0] != null)
					childComponents[0].hide(); // idRow
				fieldContainer.hide();
				fieldButtons.hide();
				snapFieldsPortsToMainPorts();

				// case Minimal:
				// 	// High optimization: Hide structural containers and internal connections completely
				// 	if (childComponents[0] != null)
				// 		childComponents[0].hide();
				// 	fieldContainer.hide();
				// 	snapFieldsPortsToMainPorts();
		}

		// TODO: this causes a bit of a stick, so we need to counter-balance by having node visibility
		invalidate();
		// Re-enable hardware optimization after changing visibility properties
		haxe.ui.Toolkit.callLater(() -> {
			this.cacheAsBitmap = true;
		});
	}

	/**
	 * Sweeps through all ports and snaps field ports to the active positions of the main ports
	 */
	private function snapFieldsPortsToMainPorts() {
		// Exact defaults based on your addPort rules
		var mainInputX:Float = -5;
		var mainInputY:Float = 10;
		var mainOutputX:Float = this.width; // Fallback bound
		var mainOutputY:Float = 10;

		// 1. Snag the definitive values directly from your main ports' current placements
		for (child in childComponents) {
			if (Std.isOfType(child, PortView)) {
				var pv:PortView = cast child;
				if (pv.data.isMain) {
					if (pv.data.direction == PortDirection.Input) {
						mainInputX = pv.left;
						mainInputY = pv.top;
					} else {
						mainOutputX = pv.left;
						mainOutputY = pv.top;
					}
				}
			}
		}

		// 2. Pass those exact positions recursively down to all nested row ports
		snapPortsRecursive(this, mainInputX, mainInputY, mainOutputX, mainOutputY);
	}

	private function snapPortsRecursive(c:haxe.ui.core.Component, inX:Float, inY:Float, outX:Float, outY:Float) {
		if (c == null)
			return;

		if (Std.isOfType(c, PortView)) {
			var pv:PortView = cast c;
			if (!pv.data.isMain) {
				pv.includeInLayout = false;
				pv.show();

				// Determine target position relative to NodeView (this)
				var targetX = (pv.data.direction == PortDirection.Input) ? inX : outX;
				var targetY = (pv.data.direction == PortDirection.Input) ? inY : outY;

				// Walk up the visual tree to find where this port is nested relative to 'this' NodeView
				var p = pv.parentComponent;
				var offsetX:Float = 0;
				var offsetY:Float = 0;

				while (p != null && p != this) {
					offsetX += p.left;
					offsetY += p.top;
					p = p.parentComponent;
				}

				// Subtract the offset of its parent container sequence so it lands perfectly on top of the main port
				pv.left = targetX - offsetX;
				pv.top = targetY - offsetY;
			}
		}

		for (child in c.childComponents) {
			snapPortsRecursive(child, inX, inY, outX, outY);
		}
	}

	/**
	 * Restores original dynamic layout anchors when zooming back in
	 */
	private function resetPortsToDefaultLayout() {
		// Rehydrate fields container components cleanly
		rebuildFields();

		// Enforce default rules for main structural layout ports
		for (child in childComponents) {
			if (Std.isOfType(child, PortView)) {
				var pv:PortView = cast child;
				pv.show();
				if (pv.data.isMain) {
					pv.includeInLayout = false;
					if (pv.data.direction == PortDirection.Input) {
						pv.left = -5;
					} else {
						var pw = (pv.width > 0) ? pv.width : 10;
						pv.left = this.width - (pw / 2);
					}
					pv.top = 10;
				}
			}
		}
	}
}
