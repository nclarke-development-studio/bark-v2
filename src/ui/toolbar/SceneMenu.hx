package ui.toolbar;

import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import ui.dialogs.NewSceneDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class SceneMenu extends Menu {
	var editor:EditorController;

	public function new(editor:EditorController) {
		super();
		this.editor = editor;

		text = "Scene";

		addComponent(newSceneItem());
		addComponent(editSceneItem());
		addComponent(duplicateSceneItem());
		addComponent(openSceneItem());
		addComponent(saveSceneItem());
		// addComponent(deleteSceneItem());
		addComponent(exportSceneItem());
	}

	function newSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "New";
		item.onClick = _ -> {
			var dialog = new NewSceneDialog();
			dialog.onConfirm = name -> {
				editor.createScene(name);
				editor.switchScene(name);
			};
			dialog.showDialog();
		};
		return item;
	}

	function editSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Edit";
		item.onClick = _ -> {
			var dialog = new NewSceneDialog();
			dialog.sceneNameText = editor.workspace.getActiveScene().id;
			dialog.onConfirm = name -> editor.renameScene(editor.workspace.getActiveScene().id, name);
			dialog.showDialog();
		};
		return item;
	}

	function duplicateSceneItem():MenuItem {
		var item = new MenuItem();
		item.text = "Duplicate";
		item.onClick = _ -> editor.duplicateScene();
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
		item.disabled = Lambda.count(editor.workspace.scenes) <= 1;

		item.onClick = _ -> {
			var sceneId = editor.workspace.activeSceneId;
			Dialogs.messageBox('Delete scene "$sceneId"?\n\nThis action cannot be undone.', "Delete Scene", MessageBoxType.TYPE_WARNING, true, button -> {
				if (button == DialogButton.OK) {
					editor.deleteScene(sceneId);
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
}
