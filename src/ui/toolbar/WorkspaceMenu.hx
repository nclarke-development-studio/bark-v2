package ui.toolbar;

import ui.dialogs.NewWorkspaceDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class WorkspaceMenu extends Menu {
	var editor:EditorController;

	public function new(editor:EditorController) {
		super();
		this.editor = editor;

		text = "Workspace";

		addComponent(newMenuItem());
		addComponent(openMenuItem());
		addComponent(saveMenuItem());
		addComponent(editMenuItem());
		addComponent(exportMenuItem());
	}

	function newMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "New";
		item.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.onConfirm = name -> {
				trace('new workspace created');
				editor.newWorkspace(name);
			}
			dialog.showDialog();
		};
		return item;
	}

	function openMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Open";
		item.onClick = _ -> Dialogs.openFile(function(button, selectedFile) {
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
		return item;
	}

	function saveMenuItem():MenuItem {
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
				extensions: [{label: "bark workspace file", extension: "bark"}],
				title: "save workspace file"
			});
		};
		return item;
	}

	function editMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Edit";
		item.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.workspaceName.text = editor.workspace.name;
			dialog.onConfirm = name -> editor.renameWorkspace(name);
			dialog.showDialog();
		};
		return item;
	}

	function exportMenuItem():MenuItem {
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
				title: "export workspace"
			});
		};
		return item;
	}
}
