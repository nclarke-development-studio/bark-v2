package ui.menus;

import util.StressTest;
import haxe.ui.notifications.NotificationType;
import haxe.ui.notifications.NotificationManager;
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

		addItem("Run Stress Test (100)", e -> {
			var data = StressTest.generate(100);
			session.addNodes(data.nodes);

			NotificationManager.instance.addNotification({
				title: "Stress Test Started",
				body: "Generated 100 nodes and 99 connections.",
				type: NotificationType.Info
			});
		});
	}

	override function close() {
		super.close();
		// Return focus logic here
		// canvas.focus = true;
	}
}
