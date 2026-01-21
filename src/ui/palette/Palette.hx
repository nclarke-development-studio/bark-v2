package ui.palette;

import haxe.ui.containers.VBox;
import haxe.ui.containers.TabView;

class Palette extends VBox {
	public var controller:EditorController;

	public var nodePalette:NodePalette;
	public var scenePalette:ScenePalette;

	var tabs:TabView;

	public function new() {
		super();

		width = 200;
		percentHeight = 100;

		tabs = new TabView();
		tabs.percentWidth = 100;
		tabs.padding = 0;

		addComponent(tabs);
	}

	public function init() {
		nodePalette = new NodePalette(controller);
		scenePalette = new ScenePalette(controller);

		tabs.addComponent(nodePalette);
		tabs.addComponent(scenePalette);
	}

	public function rebuildScenes() {
		scenePalette.rebuild();
	}

	public function rebuildNodes() {
		nodePalette.rebuild();
	}
}
