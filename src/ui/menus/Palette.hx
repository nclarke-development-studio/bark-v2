package ui.menus;

import ui.canvas.NodeCanvas;
import haxe.ui.containers.Box;
import haxe.ui.containers.TabView;
import haxe.ui.notifications.NotificationData.NotificationActionData;
import haxe.ui.events.MouseEvent;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.util.GUID;
import haxe.ui.components.Button;
import haxe.ui.containers.Collapsible;
import haxe.ui.containers.VBox;

class Palette extends VBox {
	public var controller:EditorController;
	var sceneBox:VBox;

	public function new() {
		super();
		
		width = 200;
		percentHeight = 100;

		var tabs = new TabView();
		tabs.percentWidth = 100;
		tabs.padding = 0;

		var nodeBox = new VBox();
		nodeBox.text = "Nodes";
		nodeBox.percentHeight = 100;
		nodeBox.backgroundColor = 'green';

		sceneBox = new VBox();
		sceneBox.text = "Scenes";
		sceneBox.percentHeight = 100;
		sceneBox.verticalSpacing = 4;

		// rebuildScenes();

		var basicNodesContainer = new Collapsible();
		basicNodesContainer.text = "Basic Nodes";
		basicNodesContainer.width = 200;

		var customNodesContainer = new Collapsible();
		customNodesContainer.text = "Custom Nodes";
		customNodesContainer.width = 200;

		var nodeButton = new Button();
		nodeButton.text = "Node";

		var nodeButton2 = new Button();
		nodeButton2.text = "Node";
		var nodeButton3 = new Button();
		nodeButton3.text = "Node";

		makeDraggable(nodeButton, "node");
		makeDraggable(nodeButton2, "node");
		makeDraggable(nodeButton3, "node");

		var notifyButton = new Button();
		notifyButton.text = "Show Notification";
		notifyButton.onClick = function(_:MouseEvent) {
			NotificationManager.instance.addNotification({
				title: "Hello!",
				body: "This notification was triggered from the palette button.",
				actions: [
					{
						text: "OK",
						callback: function(actionData:NotificationActionData):Bool {
							trace("User clicked OK on the notification");
							return true;
						}
					}
				]
			});
		};

		basicNodesContainer.addComponent(nodeButton);
		basicNodesContainer.addComponent(notifyButton);

		customNodesContainer.addComponent(nodeButton2);
		customNodesContainer.addComponent(nodeButton3);

		nodeBox.addComponent(basicNodesContainer);
		nodeBox.addComponent(customNodesContainer);

		tabs.addComponent(nodeBox);
		tabs.addComponent(sceneBox);

		addChild(tabs);
	}

	var dragGhost:Button = null;

	function makeDraggable(button:Button, nodeType:String) {
		button.registerEvent(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			// Create a ghost copy
			dragGhost = new Button();
			dragGhost.text = button.text;
			dragGhost.alpha = 0.5; // faded
			dragGhost.width = button.width;
			dragGhost.height = button.height;

			// Add to root so it can move freely
			button.screen.addComponent(dragGhost);

			// Position at mouse
			dragGhost.x = e.screenX - dragGhost.width / 2;
			dragGhost.y = e.screenY - dragGhost.height / 2;

			// Listen for mouse move and mouse up globally
			var mouseMoveFn = function(ev:MouseEvent) {
				if (dragGhost != null) {
					dragGhost.x = ev.screenX - dragGhost.width / 2;
					dragGhost.y = ev.screenY - dragGhost.height / 2;
				}
			}

			button.screen.registerEvent(MouseEvent.MOUSE_MOVE, mouseMoveFn);

			var mouseUpFn:Dynamic = null;
			mouseUpFn = function(ev:MouseEvent) {
				if (dragGhost != null) {
					// Call editor addNode
					var dropPosition = NodeCanvas.instance.contentLayer.globalToLocal(new openfl.geom.Point(ev.screenX, ev.screenY));
					controller.addNode({
						id: GUID.uuid(),
						type: 'node',
						x: dropPosition.x,
						y: dropPosition.y,
						ports: [],
						fields: [],
					});

					// Remove ghost
					dragGhost.hide();
					dragGhost = null;

					// Remove listeners
					button.screen.unregisterEvent(MouseEvent.MOUSE_MOVE, mouseMoveFn);
					button.screen.unregisterEvent(MouseEvent.MOUSE_UP, mouseUpFn);
				}
			};

			button.screen.registerEvent(MouseEvent.MOUSE_UP, mouseUpFn);
		});
	}

	public function rebuildScenes():Void {
		sceneBox.removeAllComponents();

		for (sceneId in controller.workspace.scenes.keys()) {
			var btn = new Button();
			btn.text = sceneId;
			btn.percentWidth = 100;

			// Highlight active scene
			if (sceneId == controller.workspace.activeSceneId) {
				btn.addClass("active-scene");
			}

			btn.onClick = _ -> {
				controller.switchScene(sceneId);
				rebuildScenes(); // refresh highlight
			};

			sceneBox.addComponent(btn);
		}

		var addBtn = new Button();
		addBtn.text = "+ Add Scene";
		addBtn.onClick = _ -> {
			var id = "scene_" + GUID.uuid().substr(0, 4);
			controller.createScene(id);
			controller.switchScene(id);
			rebuildScenes();
		};
		sceneBox.addComponent(addBtn);
	}
}
@:xml('

')
