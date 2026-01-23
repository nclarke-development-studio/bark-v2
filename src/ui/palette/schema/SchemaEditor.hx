package ui.palette.schema;

import core.EditorSession;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.HBox;
import core.Workspace;
import data.NodeData.NodeGroupSchema;
import haxe.ui.containers.dialogs.Dialog;

class SchemaEditor extends Dialog {
	public function new(workspace:Workspace, ?schema:NodeGroupSchema, ?onClose:(NodeGroupSchema) -> Void) {
		super();

		var root = new HBox();

		title = schema != null ? schema.name : "New Schema";

		var canvas = new NodeCanvas();
		var palette = new SchemaEditorPalette();
		var session = new EditorSession();

		// TODO: maybe use the same session?
		session.workspace = workspace;

		if (schema != null) {
			session.createNodes(schema, 100, 100);
		}

		var editorBinder = new SchemaEditorBinder(session, canvas, palette, schema, (schema) -> {
			if (onClose != null)
				onClose(schema);
			hide();
		});

		root.addComponent(palette);
		root.addComponent(canvas);

		root.percentHeight = root.percentWidth = 100;

		percentWidth = percentHeight = 80;

		addComponent(root);
	}
}
