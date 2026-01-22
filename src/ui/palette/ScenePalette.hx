package ui.palette;

import core.Workspace;
import ui.dialogs.NewSceneDialog;
import haxe.ui.containers.VBox;
import haxe.ui.components.Button;

class ScenePalette extends VBox {
	public var onSceneSelect:(id:String) -> Void;
	public var onSceneCreate:(id:String) -> Void;

	public function new() {
		super();

		text = "Scenes";
		percentHeight = 100;
		verticalSpacing = 4;
	}

	public function rebuild(workspace:Workspace):Void {
		removeAllComponents();

		for (scene in workspace.scenes) {
			var btn = new Button();
			btn.text = scene.id;
			btn.percentWidth = 100;

			if (scene.id == workspace.activeSceneId) {
				btn.addClass("active-scene");
			}

			btn.onClick = _ -> {
				// switchScene(sceneId);
				// rebuild();
				if (onSceneSelect != null)
					onSceneSelect(scene.id);
			};

			addComponent(btn);
		}

		var addBtn = new Button();
		addBtn.text = "+ Add Scene";
		addBtn.onClick = _ -> {
			var dialog = new NewSceneDialog();
			dialog.onConfirm = name -> {
				// controller.createScene(name);
				// controller.switchScene(name);
				// rebuild();

				if (onSceneCreate != null)
					onSceneCreate(name);

				if (onSceneSelect != null)
					onSceneSelect(name);
			};
			dialog.showDialog();
		};

		addComponent(addBtn);
	}
}
