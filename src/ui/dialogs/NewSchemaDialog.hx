package ui.dialogs;

import util.ArrayUtils;
import core.Workspace;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.events.UIEvent;

// lets us shake/do other animations w/ .shake and others
using haxe.ui.animation.AnimationTools;

@:build(haxe.ui.macros.ComponentMacros.build("assets/components/new-schema.xml"))
class NewSchemaDialog extends Dialog {
	public var onConfirm:String->Void;

	private var _w:Workspace;

	// @:bind(schemaName.text)
	// public var schemaNameText:String = "";
	// TODO: this doesn't work correctly, no reactive typing
	// change this to a property with a setter to react to typing
	public var schemaNameText(get, set):String;

	private function get_schemaNameText():String
		return schemaName.text;

	private function set_schemaNameText(value:String):String {
		schemaName.text = value;
		trace('test');
		checkDuplicate(value);
		return value;
	}

	public function new(w:Workspace) {
		super();
		_w = w;
		buttons = DialogButton.CANCEL | DialogButton.OK;
	}

	private function checkDuplicate(name:String) {
		if (name == null || name == "") {
			nameWarning.hidden = true;
			false;
		}

		// Show warning if it exists in the workspace
		var exists = ArrayUtils.exists(_w.schemas, n -> n.name == name);
		nameWarning.hidden = !exists;

		// disable the OK button visually if it exists
		// var okButton = _but[1];
		// if (okButton != null)
		// 	okButton.disabled = exists;

		return exists;
	}

	override function validateDialog(button:DialogButton, fn:Bool->Void) {
		if (button == DialogButton.OK) {
			if (schemaNameText == null || schemaNameText == "") {
				fn(false);
				return;
			}

			if (checkDuplicate(schemaNameText)) {
				fn(false);
				this.shake();
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
