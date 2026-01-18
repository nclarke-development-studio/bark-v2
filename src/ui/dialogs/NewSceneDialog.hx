package ui.dialogs;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.UIEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/components/new-scene.xml"))
class NewSceneDialog extends Dialog {
	public var onConfirm:String->Void;

	@:bind(sceneName.text)
	public var sceneNameText:String = "";

	public function new() {
		super();
		buttons = DialogButton.CANCEL | DialogButton.OK;
	}

	override function validateDialog(button:DialogButton, fn:Bool->Void) {
		if (button == DialogButton.OK && sceneName.text == "") {
			fn(false);
			return;
		}
		fn(true);
	}

	@:bind(this, DialogEvent.DIALOG_CLOSED)
	function onDialogClose(e:DialogEvent) {
		if (e.button == DialogButton.OK && onConfirm != null) {
			onConfirm(sceneName.text);
		}
	};
}
