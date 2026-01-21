package ui.palette;

import haxe.Resource;
import haxe.Json;
import openfl.geom.Point;
import ui.canvas.NodeCanvas;
import data.NodeData;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Collapsible;
import haxe.ui.components.Button;
import haxe.ui.events.MouseEvent;
import haxe.ui.util.GUID;
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
	public var controller:EditorController;

	var dragGhost:Button = null;
	var builtInSchemas:Array<NodeGroupSchema> = [];
	var workspaceSchemas:Array<NodeGroupSchema> = [];

	public function new(controller:EditorController) {
		super();
		this.controller = controller;

		text = "Nodes";
		percentHeight = 100;

		loadSchemas();
		rebuild();
	}

	function loadSchemas():Void {
		var raw = Resource.getString("nodes/builtin.json");
		var parsed = Json.parse(raw);
		workspaceSchemas = controller.workspace.schemas;
		builtInSchemas = parsed.nodes;
	}

	public function rebuild():Void {
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
		for (schema in workspaceSchemas) {
			var btn = new Button();
			btn.text = schema.name;
			btn.percentWidth = 100;

			makeDraggable(btn, schema);
			customContainer.addComponent(btn);
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
					var dropPosition = NodeCanvas.instance.contentLayer.globalToLocal(new openfl.geom.Point(e.screenX, e.screenY));

					controller.pasteSchema(schema, dropPosition.x, dropPosition.y);

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
