package ui.menus;

import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import ui.dialogs.NewSceneDialog;
import ui.dialogs.NewWorkspaceDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.CollapsibleDialog;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;

class Toolbar extends MenuBar {
	var editor:EditorController;

	public function new(e:EditorController) {
		super();

		editor = e;

		percentWidth = 100;

		var menu1 = new Menu();
		menu1.text = "Workspace";

		var newWorkspaceItem = new MenuItem();
		newWorkspaceItem.text = "New";
		// newWorkspaceItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');
		newWorkspaceItem.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.onConfirm = name -> {
				editor.newWorkspace(name);
			};
			dialog.showDialog();
		};

		var openWorkspaceItem = new MenuItem();
		openWorkspaceItem.text = "Open";
		openWorkspaceItem.onClick = (e:MouseEvent) -> Dialogs.openFile(function(button, selectedFile) {
			if (button == DialogButton.OK) {
				trace(selectedFile);
			}
		}, {
			readContents: true,
			title: "Open Workspace File",
			readAsBinary: true,
			multiple: false,
			extensions: [{label: "bark dialogue project", extension: "bark"}]
		});

		var saveWorkspaceItem = new MenuItem();
		saveWorkspaceItem.text = "Save";
		saveWorkspaceItem.onClick = (e:MouseEvent) -> {
			Dialogs.saveFile(function(button, success, path) {
				if (button == DialogButton.OK && success) {
					trace(path);
				}
			}, {
				name: 'filename',
				text: "",
				bytes: null,
				isBinary: false
			}, {
				writeAsBinary: false,
				extensions: [{label: "bark workspace file", extension: "bark"}],
				title: "save workspace file"
			});
		};

		var editWorkspaceItem = new MenuItem();
		editWorkspaceItem.text = "Edit";
		editWorkspaceItem.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.workspaceName.text = editor.workspace.name;
			dialog.onConfirm = name -> {
				editor.newWorkspace(name);
			};
			dialog.showDialog();
		};

		var exportWorkspaceItem = new MenuItem();
		exportWorkspaceItem.text = "Export";
		exportWorkspaceItem.onClick = (e:MouseEvent) -> {
			Dialogs.saveFile(function(button, success, path) {
				if (button == DialogButton.OK && success) {
					trace(path);
				}
			}, {
				name: 'filename',
				text: "",
				bytes: null,
				isBinary: false
			}, {
				writeAsBinary: false,
				extensions: [{label: "bark dialogue file", extension: "bark"}],
				title: "export workspace"
			});
		};

		menu1.addComponent(newWorkspaceItem);
		menu1.addComponent(openWorkspaceItem);
		menu1.addComponent(saveWorkspaceItem);
		menu1.addComponent(editWorkspaceItem);
		menu1.addComponent(exportWorkspaceItem);

		var menu2 = new Menu();
		menu2.text = "Scene";

		var newSceneItem = new MenuItem();
		newSceneItem.text = "New";
		// newSceneItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');
		newSceneItem.onClick = _ -> {
			var dialog = new NewSceneDialog();
			dialog.onConfirm = name -> {
				editor.createScene(name);
				editor.switchScene(name);
			};
			dialog.showDialog();
		};

		var editSceneItem = new MenuItem();
		editSceneItem.text = "Edit";
		// editSceneItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');
		editSceneItem.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.workspaceName.text = editor.workspace.name;
			dialog.onConfirm = name -> {
				editor.newWorkspace(name);
			};
			dialog.showDialog();
		};

		var openSceneItem = new MenuItem();
		openSceneItem.text = "Open";
		openSceneItem.onClick = (e:MouseEvent) -> Dialogs.openFile(function(button, selectedFile) {
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

		var saveSceneItem = new MenuItem();
		saveSceneItem.text = "Save";
		saveSceneItem.onClick = (e:MouseEvent) -> {
			Dialogs.saveFile(function(button, success, path) {
				if (button == DialogButton.OK && success) {
					trace(path);
				}
			}, {
				name: 'filename',
				text: "",
				bytes: null,
				isBinary: false
			}, {
				writeAsBinary: false,
				extensions: [{label: "bark dialogue file", extension: "bark"}],
				title: "save scene file"
			});
		};

		var deleteSceneItem = new MenuItem();
		deleteSceneItem.text = "Delete";
		deleteSceneItem.disabled = Lambda.count(editor.workspace.scenes) <= 1;
		deleteSceneItem.onClick = _ -> {
			var sceneId = editor.workspace.activeSceneId;

			Dialogs.messageBox('Delete scene "$sceneId"?\n\nThis action cannot be undone.', "Delete Scene", MessageBoxType.TYPE_WARNING, true, (button) -> {
				if (button == DialogButton.OK) {
					editor.deleteScene(sceneId);
				}
			});
		};

		var exportSceneItem = new MenuItem();
		exportSceneItem.text = "Export";
		exportSceneItem.onClick = (e:MouseEvent) -> {
			Dialogs.saveFile(function(button, success, path) {
				if (button == DialogButton.OK && success) {
					trace(path);
				}
			}, {
				name: 'filename',
				text: "",
				bytes: null,
				isBinary: false
			}, {
				writeAsBinary: false,
				extensions: [{label: "bark dialogue file", extension: "bark"}],
				title: "save scene file"
			});
		};

		var duplicateSceneItem = new MenuItem();
		duplicateSceneItem.text = "Duplicate";
		duplicateSceneItem.onClick = _ -> editor.duplicateScene();

		menu2.addComponent(newSceneItem);
		menu2.addComponent(editSceneItem);
		menu2.addComponent(duplicateSceneItem);
		menu2.addComponent(openSceneItem);
		menu2.addComponent(saveSceneItem);
		menu2.addComponent(deleteSceneItem);
		menu2.addComponent(exportSceneItem);

		var menu3 = new Menu();
		menu3.text = "Help";

		var usageItem = new MenuItem();
		usageItem.text = "Usage";
		usageItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');

		var aboutItem = new MenuItem();
		aboutItem.text = "About";
		aboutItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');

		menu3.addComponent(usageItem);
		menu3.addComponent(aboutItem);

		addComponent(menu1);
		addComponent(menu2);
		addComponent(menu3);
	}
}
