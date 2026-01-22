package ui.palette;

import core.EditorSession;
import ui.canvas.NodeCanvas;
import haxe.ui.containers.HBox;
import core.Workspace;
import data.NodeData.NodeGroupSchema;
import haxe.ui.containers.dialogs.Dialog;

class SchemaEditor extends Dialog {
	public function new(?schema:NodeGroupSchema, workspace:Workspace) {
		super();

		var root = new HBox();

		title = schema != null ? schema.name : "New Schema";

		var canvas = new NodeCanvas();
		var palette = new SchemaEditorPalette();
		var session = new EditorSession();

		var editorBinder = new SchemaEditorBinder(session, canvas, palette);

		root.addComponent(palette);
		root.addComponent(canvas);

		root.percentHeight = root.percentWidth = 100;

		percentWidth = percentHeight = 80;

		addComponent(root);
	}
}
