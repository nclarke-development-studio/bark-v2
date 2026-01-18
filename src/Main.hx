package;

import ui.menus.Toolbar;
import ui.menus.Palette;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.Toolkit;
import haxe.CallStack;
import ui.EditorController;
import ui.canvas.NodeCanvas;
import haxe.ui.HaxeUIApp;

class Main {
	public static function main() {
		Toolkit.init();
		try {
			var app = new HaxeUIApp();
			app.title = "Bark Dialogue Editor";

			app.ready(function() {
				var root = new VBox();
				root.percentWidth = 100;
				root.percentHeight = 100;
				root.verticalSpacing = 0;

				var canvas = new NodeCanvas();
				var palette = new Palette();
				var editor = new EditorController(canvas, palette);

				var toolbar = new Toolbar(editor);

				root.addComponent(toolbar);

				var mainHBox = new HBox();
				mainHBox.percentWidth = 100;
				mainHBox.percentHeight = 100;
				mainHBox.horizontalSpacing = 0;



				editor.addNode({
					id: "root",
					type: 'node',
					x: 50,
					y: 50,
					ports: [],
					fields: [],
				});


				mainHBox.addComponent(palette);
				mainHBox.addComponent(canvas);

				root.addComponent(mainHBox);

				app.addComponent(root);

				app.start();
			});
		} catch (e:Dynamic) {
			trace(e);
			trace(CallStack.toString(CallStack.exceptionStack()));
		}
	}
}
