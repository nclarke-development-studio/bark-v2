package ui.palette;

import ui.palette.schema.SchemaEditor;
import core.Workspace;
import haxe.Resource;
import haxe.Json;
import data.NodeData;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Collapsible;
import haxe.ui.components.Button;
import haxe.ui.events.MouseEvent;
#if !js
import sys.io.File;
#end
#if js
import js.Browser;
#end
#if nodejs
import js.node.Fs;
#end

class NodePalette extends VBox {
	var dragGhost:Button = null;
	var showCreateNodeButton:Bool;

	public var onNodeDrop:(nodeGroup:NodeGroupSchema, x:Float, y:Float) -> Void;
	public var onSchemaCreate:(NodeGroupSchema) -> Void;

	var builtInSchemas:Array<NodeGroupSchema> = [];

	// var workspaceSchemas:Array<NodeGroupSchema> = [];

	public function new(show:Bool = true) {
		super();

		showCreateNodeButton = show;

		text = "Nodes";
		percentHeight = 100;

		loadSchemas();
	}

	function loadSchemas():Void {
		var raw = Resource.getString("nodes/builtin.json");
		var parsed = Json.parse(raw);
		builtInSchemas = parsed.nodes;
	}

	public function rebuild(workspace:Workspace):Void {
		removeAllComponents();

		var builtInContainer = new Collapsible();
		builtInContainer.text = "Builtin Nodes";
		builtInContainer.width = 200;

		for (schema in builtInSchemas) {
			var btn = new Button();
			btn.text = schema.name;
			btn.percentWidth = 100;

			makeDraggable(btn, schema);
			builtInContainer.addComponent(btn);
		}

		addComponent(builtInContainer);

		var customContainer = new Collapsible();
		customContainer.text = "Workspace Nodes";
		customContainer.width = 200;
		for (schema in workspace.schemas) {
			var btn = new Button();
			btn.text = schema.name;
			btn.percentWidth = 100;

			makeDraggable(btn, schema);
			customContainer.addComponent(btn);
		}
		if (showCreateNodeButton) {
			var addBtn = new Button();
			addBtn.text = "+ Create Node";
			addBtn.onClick = _ -> {
				var dialog = new SchemaEditor(workspace, null, (schema) -> if (onSchemaCreate != null) onSchemaCreate(schema));
				dialog.showDialog();
			};
			customContainer.addComponent(addBtn);
		}
		addComponent(customContainer);
	}

	function makeDraggable(button:Button, schema:NodeGroupSchema):Void {
		button.registerEvent(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			dragGhost = new Button();
			dragGhost.text = button.text;
			dragGhost.alpha = 0.5;
			dragGhost.width = button.width;
			dragGhost.height = button.height;

			button.screen.addComponent(dragGhost);
			updateGhost(e);

			var mouseMoveFn = function(e:MouseEvent) {
				if (dragGhost != null) {
					updateGhost(e);
				}
			};

			var mouseUpFn:Dynamic = null;
			mouseUpFn = function(e:MouseEvent) {
				if (dragGhost != null) {
					if (onNodeDrop != null) {
						onNodeDrop(schema, e.screenX, e.screenY);
					}

					dragGhost.hide();
					dragGhost = null;

					button.screen.unregisterEvent(MouseEvent.MOUSE_MOVE, mouseMoveFn);
					button.screen.unregisterEvent(MouseEvent.MOUSE_UP, mouseUpFn);
				}
			};

			button.screen.registerEvent(MouseEvent.MOUSE_MOVE, mouseMoveFn);
			button.screen.registerEvent(MouseEvent.MOUSE_UP, mouseUpFn);
		});
	}

	function updateGhost(e:MouseEvent):Void {
		dragGhost.x = e.screenX - dragGhost.width / 2;
		dragGhost.y = e.screenY - dragGhost.height / 2;
	}

	// function createNodeFromSchema(schema:SchemaNode, e:MouseEvent):Void {
	// 	var localPos = NodeCanvas.instance.contentLayer.globalToLocal(new Point(e.screenX, e.screenY));
	// 	var fields:Array<NodeField> = [];
	// 	if (schema.fields != null) {
	// 		for (f in schema.fields) {
	// 			fields.push(schemaFieldToNodeField(f));
	// 		}
	// 	}
	// 	var node:NodeData = {
	// 		id: GUID.uuid(),
	// 		type: schema.type,
	// 		x: localPos.x,
	// 		y: localPos.y,
	// 		ports: [],
	// 		fields: fields
	// 	};
	// 	controller.addNode(node);
	// }
	// function schemaFieldToNodeField(f:SchemaField):NodeField {
	// 	return {
	// 		key: f.key,
	// 		type: f.type,
	// 		value: (f.type == "data") ? null : f.value,
	// 		portId: (f.type == "data") ? GUID.uuid() : null
	// 	};
	// }
}
