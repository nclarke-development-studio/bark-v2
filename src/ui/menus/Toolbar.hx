package ui.menus;

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
		newWorkspaceItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');

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
		editWorkspaceItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');

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
		newSceneItem.onClick = (e:MouseEvent) -> Dialogs.messageBox('Info message content\n\nLine1\nLine2\nLine3\n\nSomething else', 'Info', 'info');

		var openSceneItem = new MenuItem();
		openSceneItem.text = "Open Dialogue File";
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

		menu2.addComponent(newSceneItem);
		menu2.addComponent(openSceneItem);
		menu2.addComponent(saveSceneItem);
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
