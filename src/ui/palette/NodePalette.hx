package ui.palette;

import haxe.ui.notifications.NotificationType;
import haxe.ui.notifications.NotificationManager;
import core.Workspace;
import haxe.Resource;
import haxe.Json;
import data.NodeData;
import haxe.ui.containers.VBox;
import haxe.ui.containers.Collapsible;
import haxe.ui.components.Button;
import haxe.ui.events.MouseEvent;

class NodePalette extends VBox {
	var dragGhost:Button = null;
	var showCreateNodeButton:Bool;

	public var onNodeDrop:(nodeGroup:NodeGroupSchema, x:Float, y:Float) -> Void;
	public var onSchemaCreate:(NodeGroupSchema) -> Void;
	public var onRequestSchemaMode:() -> Void;

	var builtInSchemas:Array<NodeGroupSchema> = [];

	public function new(show:Bool = true) {
		super();

		showCreateNodeButton = show;

		text = "Nodes";
		percentHeight = 100;

		loadSchemas();
	}

	function loadSchemas():Void {
		try {
			var raw = Resource.getString("nodes/builtin.json");
			if (raw == null) {
				NotificationManager.instance.addNotification({
					title: "Resource Error",
					body: "Could not find 'nodes/builtin.json' in application resources.",
					type: NotificationType.Error
				});
				builtInSchemas = [];
				return;
			}

			var parsed = Json.parse(raw);

			if (parsed == null || !Reflect.hasField(parsed, "nodes") || !Std.isOfType(parsed.nodes, Array)) {
				NotificationManager.instance.addNotification({
					title: "Data Error",
					body: "builtin.json is missing the 'nodes' array.",
					type: NotificationType.Error
				});
				builtInSchemas = [];
				return;
			}

			builtInSchemas = parsed.nodes;

		} catch (e:Dynamic) {
			// 4. Catch unexpected crashes (like malformed JSON syntax)
			NotificationManager.instance.addNotification({
				title: "Critical Load Error",
				body: "Failed to parse built-in nodes: " + Std.string(e),
				type: NotificationType.Error,
				expiryMs: -1 // Keep visible so user can see the error details
			});
			builtInSchemas = [];
		}
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
				if (onRequestSchemaMode != null) {
					onRequestSchemaMode();
				}
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

					dragGhost.disposeComponent();
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
}
