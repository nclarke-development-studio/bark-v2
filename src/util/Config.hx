package util;

import sys.io.File;
import sys.FileSystem;
import haxe.Json;

typedef AppConfig = {
	var isFirstRun:Bool;
	var lastOpenedProject:String;
}

class Config {
	private static inline var CONFIG_FILE = "config.json";
	public static var current:AppConfig;

	public static function load() {
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
	}

	public static function save() {
		var content = Json.stringify(current, null, "    ");
		File.saveContent(CONFIG_FILE, content);
	}

	public static function setFirstRunComplete() {
		current.isFirstRun = false;
		save();
	}
}
