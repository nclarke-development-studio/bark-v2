package ui.dialogs;

import openfl.net.URLRequest;
import openfl.Lib;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.VBox;

@:build(haxe.ui.macros.ComponentMacros.build("assets/views/about.xml"))
class AboutView extends VBox {
	public function new() {
		super();
	}

	@:bind(studioLink, MouseEvent.CLICK)
	private function onLinkClick(_) {
		#if js
		js.Browser.window.open(studioLink.text, "_blank");
		#elseif openfl
		// For Windows, Mac, Linux
		Lib.getURL(new URLRequest(studioLink.text));
		#end
	}
}
