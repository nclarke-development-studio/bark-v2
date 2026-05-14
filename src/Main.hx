package;

import ui.menus.GraphContextMenu;
import ui.dialogs.UsageView;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.events.KeyboardEvent;
import util.KeyCodes;
import ui.nodes.NodeFactory;
import ui.EditorBinder;
import core.EditorSession;
import ui.toolbar.Toolbar;
import ui.palette.Palette;
import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.Toolkit;
import haxe.CallStack;
import ui.canvas.NodeCanvas;
import haxe.ui.HaxeUIApp;
import util.Config;

class Main {
	public static function main() {
		Config.load();
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
				var toolbar = new Toolbar();
				var session = new EditorSession();

				var editorBinder = new EditorBinder(session, canvas, palette, toolbar);

				session.createWorkspace('default');

				root.addComponent(toolbar);

				var mainHBox = new HBox();
				mainHBox.percentWidth = 100;
				mainHBox.percentHeight = 100;
				mainHBox.horizontalSpacing = 0;

				session.addNode(NodeFactory.createNode('source', 100, 100, 'root'));

				mainHBox.addComponent(palette);
				mainHBox.addComponent(canvas);

				root.addComponent(mainHBox);

				root.tabIndex = 0;

				app.addComponent(root);

				haxe.ui.core.Screen.instance.registerEvent(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent) -> {
					switch (e.keyCode) {
						case KeyCodes.S:
							if (e.ctrlKey) {
								session.saveWorkspace();
							}
					}
				});

				if (Config.current.isFirstRun) {
					showOnboarding();
					Config.setFirstRunComplete();
				}

				app.start();
			});
		} catch (e:Dynamic) {
			trace(e);
			trace(CallStack.toString(CallStack.exceptionStack()));
		}
	}

	static function showOnboarding() {
		haxe.ui.containers.dialogs.Dialogs.dialog(new UsageView(), "Bark Usage", DialogButton.OK);
	}
}
