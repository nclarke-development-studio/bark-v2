package ui.palette;

import data.NodeData.NodeGroupSchema;
import core.Workspace;
import haxe.ui.containers.VBox;
import haxe.ui.containers.TabView;

class Palette extends VBox {
	public var nodePalette:NodePalette;
	public var scenePalette:ScenePalette;

	var tabs:TabView;

	// callbacks
	public var onRequestSceneSelect:(id:String) -> Void;
	public var onRequestSceneCreate:(id:String) -> Void;
	public var onRequestNodeDrop:(NodeGroupSchema, Float, Float) -> Void;
	public var onRequestSchemaCreate:(NodeGroupSchema) -> Void;
	public var onRequestSchemaMode:() -> Void;

	public function new() {
		super();

		width = 200;
		percentHeight = 100;

		tabs = new TabView();
		tabs.percentWidth = 100;
		tabs.padding = 0;

		nodePalette = new NodePalette();
		scenePalette = new ScenePalette();
	}

	public function init() {
		nodePalette.onNodeDrop = onRequestNodeDrop;
		nodePalette.onSchemaCreate = onRequestSchemaCreate;
		nodePalette.onRequestSchemaMode = onRequestSchemaMode;

		scenePalette.onSceneCreate = onRequestSceneCreate;
		scenePalette.onSceneSelect = onRequestSceneSelect;

		tabs.addComponent(nodePalette);
		tabs.addComponent(scenePalette);

		addComponent(tabs);
	}

	public function rebuild(workspace:Workspace) {
		scenePalette.rebuild(workspace);
		nodePalette.rebuild(workspace);
	}

	public function rebuildScenes(workspace:Workspace) {
		scenePalette.rebuild(workspace);
	}

	public function rebuildNodes(workspace:Workspace) {
		nodePalette.rebuild(workspace);
	}
}
