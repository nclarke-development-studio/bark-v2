package ui.menus;

import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.dialogs.Dialogs;

class Toolbar extends MenuBar {
	public function new(editor:EditorController) {
		super();
		percentWidth = 100;

		addComponent(new WorkspaceMenu(editor));
		addComponent(new SceneMenu(editor));
		addComponent(helpMenu());
	}

	function helpMenu():Menu {
		var menu = new Menu();
		menu.text = "Help";

		var usage = new MenuItem();
		usage.text = "Usage";
		usage.onClick = _ -> Dialogs.messageBox("Usage info", "Usage", "info");

		var about = new MenuItem();
		about.text = "About";
		about.onClick = _ -> Dialogs.messageBox("About info", "About", "info");

		menu.addComponent(usage);
		menu.addComponent(about);
		return menu;
	}
}
