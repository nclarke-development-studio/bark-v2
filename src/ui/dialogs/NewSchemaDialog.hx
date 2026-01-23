package ui.dialogs;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.UIEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/components/new-schema.xml"))
class NewSchemaDialog extends Dialog {
	public var onConfirm:String->Void;

	@:bind(schemaName.text)
	public var schemaNameText:String = "";

	public function new() {
		super();
		buttons = DialogButton.CANCEL | DialogButton.OK;
	}

	override function validateDialog(button:DialogButton, fn:Bool->Void) {
		if (button == DialogButton.OK) {
			if (schemaNameText == null || schemaNameText == "") {
				fn(false);
				return;
			}
		}
		fn(true);
	}

	@:bind(this, DialogEvent.DIALOG_CLOSED)
	function onDialogClose(e:DialogEvent) {
		if (e.button == DialogButton.OK && onConfirm != null) {
			onConfirm(schemaNameText);
		}
	};
}
