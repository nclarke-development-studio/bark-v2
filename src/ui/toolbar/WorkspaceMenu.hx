package ui.toolbar;

import ui.dialogs.NewWorkspaceDialog;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class WorkspaceMenu extends Menu {
	public var onRequestCreateWorkspace:(String) -> Void;
	public var onRequestGetWorkspaceName:() -> String;
	public var onRequestRenameWorkspace:(String) -> Void;

	public var onRequestOpenWorkspace:() -> Void;
	public var onRequestSaveWorkspace:() -> Void;
	public var onRequestSaveAsWorkspace:() -> Void;
	public var onRequestExportWorkspace:() -> Void;

	public function new() {
		super();

		text = "Workspace";

		addComponent(newMenuItem());
		addComponent(openMenuItem());
		addComponent(editMenuItem());
		addComponent(saveMenuItem());
		addComponent(saveAsMenuItem());
		addComponent(exportMenuItem());
	}

	function newMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "New";
		item.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.onConfirm = name -> {
				if (onRequestCreateWorkspace != null)
					onRequestCreateWorkspace(name);
			}
			dialog.showDialog();
		};
		return item;
	}

	function openMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Open";
		item.onClick = _ -> {
			if (onRequestOpenWorkspace != null) {
				onRequestOpenWorkspace();
			}
		}
		return item;
	}

	function editMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Edit";
		item.onClick = _ -> {
			var dialog = new NewWorkspaceDialog();
			dialog.workspaceName.text = onRequestGetWorkspaceName();
			dialog.onConfirm = name -> onRequestRenameWorkspace(name);
			dialog.showDialog();
		};
		return item;
	}

	function saveMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Save";
		item.onClick = _ -> {
			if (onRequestSaveWorkspace != null) {
				onRequestSaveWorkspace();
			}
		};
		return item;
	}

	function saveAsMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Save As...";
		item.onClick = _ -> {
			if (onRequestSaveAsWorkspace != null) {
				onRequestSaveAsWorkspace();
			}
		};
		return item;
	}

	function exportMenuItem():MenuItem {
		var item = new MenuItem();
		item.text = "Export";
		item.onClick = _ -> {
			if (onRequestExportWorkspace != null) {
				onRequestExportWorkspace();
			}
		};
		return item;
	}

	// public function rebuild(w:Workspace) {
	// }
}
