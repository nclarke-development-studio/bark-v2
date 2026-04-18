package ui.components;

import haxe.ui.containers.VBox;
import haxe.ui.components.Button;
import haxe.ui.core.Screen;
import haxe.ui.events.MouseEvent;
import haxe.ui.util.Timer;

class ContextMenu extends VBox {
	public function new() {
		super();
		this.styleNames = "custom-context-menu";
		this.addClass("vbox");

		Timer.delay(() -> {
			Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onScreenMouseDown);
		}, 1);
	
		registerEvent(MouseEvent.CLICK, e -> {
			trace('clicked');
			e.cancel();
		});
	}

	public function addItem(text:String, onClick:MouseEvent->Void):Button {
		var item = new Button();
		item.text = text;
		item.styleNames = "menu-item-button";
		item.percentWidth = 100;
		item.onClick = e -> {
			e.cancel();
			onClick(e);
			close();
		};
		addComponent(item);
		return item;
	}

	private function onScreenMouseDown(e:MouseEvent) {
		if (this.hitTest(e.screenX, e.screenY)) {
			return;
		}
		close();
	}

	public function close() {
		Screen.instance.unregisterEvent(MouseEvent.MOUSE_DOWN, onScreenMouseDown);
		if (this.parentComponent != null) {
			this.parentComponent.removeComponent(this);
		}

		// Dispatch a custom event so the caller knows it closed
		dispatch(new MouseEvent(MouseEvent.MOUSE_OUT));
	}
}
