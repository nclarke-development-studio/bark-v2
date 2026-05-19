package util;

#if !js
import sys.io.File;
import sys.FileSystem;
#elseif js
import js.Browser;
#end
import haxe.Json;

typedef AppConfig = {
	var isFirstRun:Bool;
	var lastOpenedProject:String;
}

class Config {
	private static inline var CONFIG_FILE = "config.json";
	public static var current:AppConfig;

	public static function load() {
		#if js
		var content = Browser.window.localStorage.getItem(CONFIG_FILE);
		if (content == null) {
			current = {
				isFirstRun: true,
				lastOpenedProject: "",
			};
			save();
		} else {
			try {
				current = Json.parse(content);
			} catch (e:Dynamic) {
				current = {isFirstRun: true, lastOpenedProject: ""};
			}
		}
		#else
		if (!FileSystem.exists(CONFIG_FILE)) {
			current = {
				isFirstRun: true,
				lastOpenedProject: "",
			};
			save();
		} else {
			var content = File.getContent(CONFIG_FILE);
			current = Json.parse(content);
		}
		#end
	}

	public static function save() {
		var content = Json.stringify(current, null, "    ");
		#if js
		Browser.window.localStorage.setItem(CONFIG_FILE, content);
		#else
		File.saveContent(CONFIG_FILE, content);
		#end
	}

	public static function setFirstRunComplete() {
		current.isFirstRun = false;
		save();
	}
}
