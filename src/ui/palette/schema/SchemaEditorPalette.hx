package ui.palette.schema;

import haxe.ui.components.Button;
import data.NodeData.NodeGroupSchema;
import core.Workspace;
import haxe.ui.containers.VBox;
import haxe.ui.containers.TabView;

class SchemaEditorPalette extends VBox {
	public var nodePalette:NodePalette;
	public var scenePalette:ScenePalette;

	var tabs:TabView;

	// callbacks
	public var onRequestNodeDrop:(NodeGroupSchema, Float, Float) -> Void;
	public var onRequestSaveSchema:() -> Void;

	public function new() {
		super();

		width = 200;
		percentHeight = 100;

		tabs = new TabView();
		tabs.percentWidth = 100;
		tabs.padding = 0;

		nodePalette = new NodePalette(false);
	}

	public function init() {
		nodePalette.onNodeDrop = onRequestNodeDrop;

		var saveButton = new Button();
		saveButton.text = '+ Save Schema';
		saveButton.onClick = _ -> onRequestSaveSchema();

		addComponent(saveButton);

		tabs.addComponent(nodePalette);
		addComponent(tabs);
	}

	public function rebuild(workspace:Workspace) {
		nodePalette.rebuild(workspace);
	}
}
