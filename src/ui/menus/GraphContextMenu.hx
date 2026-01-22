package ui.menus;

import data.PortData.PortDirection;
import haxe.ui.util.GUID;
import core.EditorSession;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class GraphContextMenu extends Menu {
	public function new(canvas:NodeCanvas, session:EditorSession) {
		super();

		var addNodeItem = new MenuItem();
		addNodeItem.text = "Add Node";
		addNodeItem.onClick = _ -> {
			var contentX = (canvas.mouseX - canvas.contentLayer.left) / canvas.contentLayer.scaleX;
			var contentY = (canvas.mouseY - canvas.contentLayer.top) / canvas.contentLayer.scaleY;
			session.addNode({
				id: GUID.uuid(),
				type: 'basic',
				x: contentX,
				y: contentY,
				ports: [
					{
						id: GUID.uuid(),
						name: 'mainSource',
						direction: PortDirection.Output,
						isMain: true,
					},
					{
						id: GUID.uuid(),
						name: 'mainTarget',
						direction: PortDirection.Input,
						isMain: true
					}
				],
				fields: []
			});
		};
		addComponent(addNodeItem);
		//

		var saveItem = new MenuItem();
		saveItem.text = "Save Graph";
		saveItem.onClick = _ -> {
			session.saveScene();
		};
		addComponent(saveItem);

		// var loadItem = new MenuItem();
		// loadItem.text = "Load Graph";
		// loadItem.onClick = _ -> {
		// 	session.loadScene();
		// };
		// addComponent(loadItem);
	}
}
