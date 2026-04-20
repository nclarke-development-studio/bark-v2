package ui.dialogs;

import core.Workspace;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.UIEvent;

using haxe.ui.animation.AnimationTools;

@:build(haxe.ui.macros.ComponentMacros.build("assets/components/new-scene.xml"))
class NewSceneDialog extends Dialog {
	public var onConfirm:String->Void;

	private var duplicateScene:String->Bool;

	public var sceneNameText(get, set):String;
	private function get_sceneNameText():String
		return sceneName.text;

	private function set_sceneNameText(value:String):String {
		sceneName.text = value;
		duplicateScene(value);
		return value;
	}

	public function new(v:String->Bool) {
		super();
		duplicateScene = v;
		buttons = DialogButton.CANCEL | DialogButton.OK;
	}

	override function validateDialog(button:DialogButton, fn:Bool->Void) {
		if (button == DialogButton.OK && (sceneName.text == "" || duplicateScene(sceneName.text))) {
			nameWarning.hidden = false;
			fn(false);
			this.shake();
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
