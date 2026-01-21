package ui.palette;

import ui.dialogs.NewSceneDialog;
import haxe.ui.containers.VBox;
import haxe.ui.components.Button;

class ScenePalette extends VBox {
	public var controller:EditorController;

	public function new(controller:EditorController) {
		super();
		this.controller = controller;

		text = "Scenes";
		percentHeight = 100;
		verticalSpacing = 4;

		rebuild();
	}

	public function rebuild():Void {
		removeAllComponents();

		for (sceneId in controller.workspace.scenes.keys()) {
			var btn = new Button();
			btn.text = sceneId;
			btn.percentWidth = 100;

			if (sceneId == controller.workspace.activeSceneId) {
				btn.addClass("active-scene");
			}

			btn.onClick = _ -> {
				controller.switchScene(sceneId);
				rebuild();
			};

			addComponent(btn);
		}

		var addBtn = new Button();
		addBtn.text = "+ Add Scene";
		addBtn.onClick = _ -> {
			var dialog = new NewSceneDialog();
			dialog.onConfirm = name -> {
				controller.createScene(name);
				controller.switchScene(name);
				rebuild();
			};
			dialog.showDialog();
		};

		addComponent(addBtn);
	}
}
