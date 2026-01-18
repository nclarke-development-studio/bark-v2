package ui.menus;

import ui.canvas.NodeCanvas;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class GraphContextMenu extends Menu {
	public function new(canvas:NodeCanvas, controller:EditorController) {
		super();

		var addNodeItem = new MenuItem();
		addNodeItem.text = "Add Node";
		addNodeItem.onClick = _ -> {
			var contentX = (canvas.mouseX - canvas.contentLayer.left) / canvas.contentLayer.scaleX;
			var contentY = (canvas.mouseY - canvas.contentLayer.top) / canvas.contentLayer.scaleY;
			controller.createNodeAt(contentX, contentY);
		};
		addComponent(addNodeItem);

		var saveItem = new MenuItem();
		saveItem.text = "Save Graph";
		saveItem.onClick = _ -> {
			controller.saveScene();
		};
		addComponent(saveItem);

		var loadItem = new MenuItem();
		loadItem.text = "Load Graph";
		loadItem.onClick = _ -> {
			controller.loadScene();
		};
		addComponent(loadItem);
	}
}
