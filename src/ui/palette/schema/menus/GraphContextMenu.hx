package ui.palette.schema.menus;

import ui.components.ContextMenu;
import data.NodeData.NodeGroupSchema;
import util.WorkspaceUtils;
import ui.dialogs.NewSchemaDialog;
import data.PortData.PortDirection;
import haxe.ui.util.GUID;
import core.EditorSession;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class GraphContextMenu extends ContextMenu {
	public function new(canvas:NodeCanvas, session:EditorSession, schema:NodeGroupSchema, ?closeSchemaEditor:(NodeGroupSchema) -> Void) {
		super();

		addItem("Add Node", _ -> {
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
		});
		//

		addItem("Save Schema", _ -> {
			var dialog = new NewSchemaDialog();
			if (schema != null) {
				dialog.schemaNameText = schema.name;
			}
			dialog.onConfirm = name -> {
				if (schema != null)
					session.removeSchemaFromWorkspace(schema.name);

				var newSchema = WorkspaceUtils.encodeSchema(name, '', session.graph.data.nodes, session.graph.data.connections);
				// session.addSchemaToWorkspace(newSchema);
				if (closeSchemaEditor != null)
					closeSchemaEditor(newSchema);
			};
			dialog.showDialog();
		});
		// var loadItem = new MenuItem();

		// loadItem.text = "Load Graph";
		// loadItem.onClick = _ -> {
		// 	session.loadScene();
		// };
		// addComponent(loadItem);
	}
}
