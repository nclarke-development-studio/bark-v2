package ui.toolbar;

import core.Workspace;
import data.SceneData;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuBar;
import haxe.ui.containers.menus.MenuItem;
import haxe.ui.containers.dialogs.Dialogs;

class Toolbar extends MenuBar {
	public var onRequestCreateScene:(String) -> Void;
	public var onRequestSwitchScene:(String) -> Void;
	public var onRequestDuplicateScene:(String) -> Void;
	public var onRequestDeleteScene:(String) -> Void;

	public var onRequestOpenScene:() -> Void;
	public var onRequestSaveScene:() -> Void;
	public var onRequestExportScene:() -> Void;

	public var onRequestGetActiveScene:() -> SceneData;
	public var onRequestGetWorkspaceScenes:() -> Array<SceneData>;
	public var onRequestRenameScene:(String, String) -> Void;

	public var onRequestCreateWorkspace:(String) -> Void;
	public var onRequestGetWorkspaceName:() -> String;
	public var onRequestRenameWorkspace:(String) -> Void;
	public var onRequestSaveWorkspace:() -> Void;
	public var onRequestOpenWorkspace:() -> Void;
	public var onRequestExportWorkspace:() -> Void;

	var workspaceM:WorkspaceMenu;
	var sceneM:SceneMenu;

	public function new() {
		super();
		percentWidth = 100;

		workspaceM = new WorkspaceMenu();
		sceneM = new SceneMenu();
	}

	public function init() {
		sceneM.onRequestCreateScene = onRequestCreateScene;
		sceneM.onRequestSwitchScene = onRequestSwitchScene;
		sceneM.onRequestDuplicateScene = onRequestDuplicateScene;
		sceneM.onRequestDeleteScene = onRequestDeleteScene;
		sceneM.onRequestSaveScene = onRequestSaveScene;
		sceneM.onRequestExportScene = onRequestExportScene;
		sceneM.onRequestOpenScene = onRequestOpenScene;

		sceneM.onRequestGetActiveScene = onRequestGetActiveScene;
		sceneM.onRequestGetWorkspaceScenes = onRequestGetWorkspaceScenes;
		sceneM.onRequestRenameScene = onRequestRenameScene;

		workspaceM.onRequestCreateWorkspace = onRequestCreateWorkspace;
		workspaceM.onRequestGetWorkspaceName = onRequestGetWorkspaceName;
		workspaceM.onRequestRenameWorkspace = onRequestRenameWorkspace;
		workspaceM.onRequestSaveWorkspace = onRequestSaveWorkspace;
		workspaceM.onRequestExportWorkspace = onRequestExportWorkspace;
		workspaceM.onRequestOpenWorkspace = onRequestOpenWorkspace;

		addComponent(workspaceM);
		addComponent(sceneM);
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

	public function rebuild(workspace:Workspace) {
		// workspaceMenu.rebuild(workspace);
		sceneM.rebuild(workspace);
	}
}
