package util;

#if !js
import sys.io.File;
import sys.FileSystem;
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
		#if !js
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
		#if !js
		var content = Json.stringify(current, null, "    ");
		File.saveContent(CONFIG_FILE, content);
		#end
	}

	public static function setFirstRunComplete() {
		#if !js
		current.isFirstRun = false;
		save();
		#end
	}
}
