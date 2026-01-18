package;

import haxe.ui.containers.VBox;
import haxe.ui.containers.HBox;
import haxe.ui.components.Button;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
	public function new() {
		super();
		button1.onClick = function(e) {
			button1.text = "Thanks!";
		}

		var hbox = new HBox();
		var button = new Button();
		button.text = "Button A";
		hbox.addComponent(button);
		var button = new Button();
		button.text = "Button B";
		hbox.addComponent(button);
		var button = new Button();
		button.text = "Button C";
		hbox.addComponent(button);
		addComponent(hbox);
	}

	@:bind(button2, MouseEvent.CLICK)
	private function onMyButton(e:MouseEvent) {
		button2.text = "Thanks!";
	}
}
