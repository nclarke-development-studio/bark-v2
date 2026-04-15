package ui.connections;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Grid;
import haxe.ui.components.*;
import haxe.ui.core.Component;
import data.ConnectionData;
import data.NodeData.NodeField;
import haxe.ui.util.GUID.uuid;

class ConnectionDataEditor extends VBox {
	public var data:ConnectionData;

	/** Fired when fields/ports change in a way that affects layout */
	public var onLayoutChanged:Void->Void;

	public function new(data:ConnectionData) {
		super();
		this.data = data;
		percentWidth = 100;
		padding = 4;

		rebuild();
	}

	public function rebuild():Void {
		removeAllComponents();
		addFieldButtons();
		populateData();
	}

	// --------------------------------------------------
	function populateData():Void {
		if (data.fields == null)
			return;

		for (field in data.fields) {
			addFieldRow(field);
		}
	}

	function addFieldRow(field:NodeField):Void {
		var grid = new Grid();
		grid.columns = 3;
		grid.percentWidth = 100;

		// key
		var keyInput = new TextField();
		keyInput.text = field.key;
		keyInput.placeholder = "Key";
		keyInput.percentWidth = 90;
		keyInput.onChange = _ -> {
			field.key = keyInput.text;
			triggerLayout();
		};
		grid.addComponent(keyInput);

		// value
		var valueInput:Component = null;

		switch (field.type) {
			case "string", "number":
				var ti = new TextField();
				ti.text = field.value;
				ti.onChange = _ -> {
					field.value = ti.text;
					invalidateLayout();
					triggerLayout();
				};
				valueInput = ti;

			case "text":
				var ta = new TextArea();
				ta.text = field.value;
				ta.height = 60;
				ta.onChange = _ -> {
					field.value = ta.text;
					invalidateLayout();
					triggerLayout();
				};
				valueInput = ta;

			case "boolean":
				var cb = new CheckBox();
				cb.selected = field.value;
				cb.onChange = _ -> {
					field.value = cb.value;
					invalidateLayout();
					triggerLayout();
				};
				valueInput = cb;

			default:
		}

		if (valueInput != null) {
			valueInput.percentWidth = 100;
			grid.addComponent(valueInput);
		}

		// delete
		var del = new Button();
		del.text = "X";
		del.onClick = _ -> {
			data.fields.remove(field);
			rebuild();

			invalidateComponentLayout();
			invalidateComponentData();

			if (parentComponent != null)
				parentComponent.invalidateComponentLayout();

			triggerLayout();
		};
		
		grid.addComponent(del);

		addComponent(grid);
	}

	// --------------------------------------------------
	function addFieldButtons():Void {
		var box = new HBox();
		box.percentWidth = 100;

		addBtn(box, "String", () -> addField("string"));
		addBtn(box, "Text", () -> addField("text"));
		addBtn(box, "Number", () -> addField("number"));
		addBtn(box, "Boolean", () -> addField("boolean"));
		addBtn(box, "Data Port", () -> addField("data"));

		addComponent(box);
	}

	function addBtn(box:HBox, label:String, fn:Void->Void) {
		var b = new Button();
		b.text = label;
		b.onClick = _ -> fn();
		box.addComponent(b);
	}

	function addField(type:String):Void {
		var f:NodeField = {
			type: type,
			key: "",
			value: null,
			portId: type == "data" ? uuid() : null
		};
		if (data.fields == null)
			data.fields = [];
		data.fields.push(f);

		rebuild();
		triggerLayout();
	}

	inline function triggerLayout() {
		if (onLayoutChanged != null)
			onLayoutChanged();
	}

	function invalidateLayout():Void {
		invalidateComponentLayout();
		invalidateComponentData();
		if (parentComponent != null)
			parentComponent.invalidateComponentLayout();
	}
}
