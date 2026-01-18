package core;

import data.*;
import haxe.Json;

#if !js
import sys.io.File;
#end

#if js
import js.Browser;
#end

#if nodejs
import js.node.Fs;
#end

class GraphSerializer {

	static inline function serialize(g:GraphData):String {
		return Json.stringify(g, "\t");
	}

	static inline function deserialize(s:String):GraphData {
		return Json.parse(s);
	}

	public static function save(path:String, g:GraphData):Void {
		var data = serialize(g);

		#if nodejs
		Fs.writeFileSync(path, data);

		#elseif js
		Browser.window.localStorage.setItem(path, data);

		#else
		// Native (cpp, hl, neko, etc.)
		File.saveContent(path, data);
		#end
	}

	public static function load(path:String):GraphData {
		var data:String;

		#if nodejs
		data = Fs.readFileSync(path, "utf8");

		#elseif js
		data = Browser.window.localStorage.getItem(path);
		if (data == null)
			throw 'No saved data for key "$path"';

		#else
		data = File.getContent(path);
		#end

		return deserialize(data);
	}
}
