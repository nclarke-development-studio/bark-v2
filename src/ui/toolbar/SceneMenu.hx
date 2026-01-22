package ui.toolbar;

import core.Workspace;
import data.SceneData;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import ui.dialogs.NewSceneDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class SceneMenu extends Menu {
	public var onRequestCreateScene:(String) -> Void;
	public var onRequestSwitchScene:(String) -> Void;
	public var onRequestDuplicateScene:(String) -> Void;
	public var onRequestDeleteScene:(String) -> Void;

	public var onRequestGetActiveScene:() -> SceneData;
	public var onRequestGetWorkspaceScenes:() -> Array<SceneData>;
	public var onRequestRenameScene:(String, String) -> Void;

	public function new() {
		super();

		text = "Scene";

		addComponent(newSceneItem());
		addComponent(editSceneItem());
		addComponent(duplicateSceneItem());
		addComponent(openSceneItem());
		addComponent(saveSceneItem());
		addComponent(deleteSceneItem());
		addComponent(exportSceneItem());
	}

	function newSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "New";
		item.onClick = _ -> {
			var dialog = new NewSceneDialog();
			dialog.onConfirm = name -> {
				if (onRequestCreateScene != null)
					onRequestCreateScene(name);

				if (onRequestSwitchScene != null)
					onRequestSwitchScene(name);
			};
			dialog.showDialog();
		};
		return item;
	}

	function editSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Edit";
		item.onClick = _ -> {
			if (onRequestGetActiveScene == null || onRequestRenameScene == null)
				return;

			var activeScene = onRequestGetActiveScene();
			if (activeScene == null)
				return;

			var dialog = new NewSceneDialog();
			dialog.sceneNameText = activeScene.id;
			dialog.onConfirm = name -> onRequestRenameScene(activeScene.id, name);
			dialog.showDialog();
		};
		return item;
	}

	function duplicateSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Duplicate";
		item.onClick = _ -> {
			if (onRequestDuplicateScene == null || onRequestGetActiveScene == null)
				return;

			var activeScene = onRequestGetActiveScene();
			if (activeScene != null)
				onRequestDuplicateScene(activeScene.id);
		};
		return item;
	}

	function openSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Open";
		item.onClick = _ -> Dialogs.openFile(function(button, selectedFile) {
			if (button == DialogButton.OK) {
				trace(selectedFile);
			}
		}, {
			readContents: true,
			title: "Open",
			readAsBinary: true,
			multiple: false,
			extensions: [{label: "bark dialogue file", extension: "bark"}]
		});
		return item;
	}

	function saveSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Save";
		item.onClick = _ -> {
			Dialogs.saveFile(function(button, success, path) {
				if (button == DialogButton.OK && success) {
					trace(path);
				}
			}, {
				name: "filename",
				text: "",
				bytes: null,
				isBinary: false
			}, {
				writeAsBinary: false,
				extensions: [{label: "bark dialogue file", extension: "bark"}],
				title: "save scene file"
			});
		};
		return item;
	}

	function deleteSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Delete";

		// initial disabled state (safe)
		item.disabled = onRequestGetWorkspaceScenes == null
			|| onRequestGetWorkspaceScenes() == null
			|| onRequestGetWorkspaceScenes().length <= 1;

		item.onClick = _ -> {
			if (onRequestDeleteScene == null || onRequestGetActiveScene == null)
				return;

			var activeScene = onRequestGetActiveScene();
			if (activeScene == null)
				return;

			var sceneId = activeScene.id;
			Dialogs.messageBox('Delete scene "$sceneId"?\n\nThis action cannot be undone.', "Delete Scene", MessageBoxType.TYPE_WARNING, true, button -> {
				if (button == DialogButton.OK) {
					onRequestDeleteScene(sceneId);
				}
			});
		};
		return item;
	}

	function exportSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Export";
		item.onClick = _ -> {
			Dialogs.saveFile(function(button, success, path) {
				if (button == DialogButton.OK && success) {
					trace(path);
				}
			}, {
				name: "filename",
				text: "",
				bytes: null,
				isBinary: false
			}, {
				writeAsBinary: false,
				extensions: [{label: "bark dialogue file", extension: "bark"}],
				title: "save scene file"
			});
		};
		return item;
	}

	public function rebuild(w:Workspace) {
		var scenes = onRequestGetWorkspaceScenes != null ? onRequestGetWorkspaceScenes() : null;

		var canDelete = scenes != null && scenes.length > 1;

		for (c in childComponents) {
			var item = Std.downcast(c, MenuItem);
			if (item != null && item.text == "Delete") {
				item.disabled = !canDelete;
			}
		}
	}
}
