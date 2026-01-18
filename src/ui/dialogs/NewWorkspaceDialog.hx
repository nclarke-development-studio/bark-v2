package ui.dialogs;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.UIEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/components/new-workspace.xml"))
class NewWorkspaceDialog extends Dialog {
	public var onConfirm:String->Void;

	@:bind(workspaceName.text)
	public var workspaceNameText:String = "";

	public function new() {
		super();
		buttons = DialogButton.CANCEL | DialogButton.OK;
	}

	override function validateDialog(button:DialogButton, fn:Bool->Void) {
		if (button == DialogButton.OK) {
			if (workspaceName.text == null || workspaceName.text == "") {
				fn(false);
				return;
			}
		}
		fn(true);
	}

	@:bind(this, DialogEvent.DIALOG_CLOSED)
	function onDialogClose(e:DialogEvent) {
		if (e.button == DialogButton.OK && onConfirm != null) {
			onConfirm(workspaceName.text);
		}
	};
}
