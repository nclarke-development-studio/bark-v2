package ui.menus;

import data.PortData.PortDirection;
import haxe.ui.util.GUID;
import core.EditorSession;
import ui.canvas.NodeCanvas;
import ui.components.ContextMenu;

class GraphContextMenu extends ContextMenu {
	public function new(canvas:NodeCanvas, session:EditorSession) {
		super();

		addItem("Add Node", e -> {
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
						isMain: true
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
		});

		addItem("Save Scene", e -> {
			session.saveScene();
		});
	}

	override function close() {
		super.close();
		// Return focus logic here
		// canvas.focus = true;
	}
}
