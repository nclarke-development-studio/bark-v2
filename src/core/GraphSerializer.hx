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

	public static function export(g:GraphData) {
		var exportedNodes = [];
		var exportedEdges = [];

		var connectionLookup:Map<String, String> = new Map();
		for (conn in g.connections) {
			connectionLookup.set(conn.fromPort, conn.id);
			connectionLookup.set(conn.toPort, conn.id);
		}

		for (node in g.nodes) {
			var exportObj:Dynamic = {
				id: node.id
			};

			var mainInputId:String = null;
			var mainOutputId:String = null;

			exportObj.prev = null;
			exportObj.next = null;

			for (p in node.ports) {
				if (p.isMain) {
					if (p.direction == Input)
						mainInputId = p.id;
					else
						mainOutputId = p.id;
				}
			}

			// assign ports via lookup
			Reflect.setField(exportObj, "prev", (mainInputId != null) ? connectionLookup.get(mainInputId) : null);
			Reflect.setField(exportObj, "next", (mainOutputId != null) ? connectionLookup.get(mainOutputId) : null);

			for (field in node.fields) {
				if (field.type == "data") {
					var edgeId = (field.portId != null) ? connectionLookup.get(field.portId) : null;
					Reflect.setField(exportObj, field.key, edgeId);
				} else {
					Reflect.setField(exportObj, field.key, field.value);
				}
			}

			exportedNodes.push(exportObj);
		}

		for (conn in g.connections) {
			var eObj:Dynamic = {
				id: conn.id,
				from: conn.fromNode,
				to: conn.toNode
			};

			if (conn.fields != null) {
				for (field in conn.fields) {
					Reflect.setField(eObj, field.key, field.value);
				}
			}
			exportedEdges.push(eObj);
		}

		var finalData = {
			nodes: exportedNodes,
			edges: exportedEdges
		};

		var finalJson = Json.stringify(finalData, "\t");

		return finalJson;
	}

	public static function save(g:GraphData):String {
		var data = serialize(g);

		return data;
	}

	public static function serializeWorkspace(w:Workspace):String {
		var data:WorkspaceData = {
			name: w.name,
			activeSceneId: w.activeSceneId,
			scenes: [for (s in w.scenes) s],
			schemas: w.schemas
		};
		return Json.stringify(data, "\t");
	}

	public static function exportWorkspace(w:Workspace):String {
		var exportedScenes = [];
		for (scene in w.scenes) {
			var exportedGraph = Json.parse(export(scene.graph));
			exportedScenes.push({
				id: scene.id,
				graph: exportedGraph
			});
		}

		var finalData = {
			workspaceName: w.name,
			scenes: exportedScenes
		};

		return Json.stringify(finalData, "\t");
	}

	public static function getExportFiles(w:Workspace):Map<String, String> {
		var files = new Map<String, String>();

		for (scene in w.scenes) {
			var fileName = '${scene.id}.json';
			var exportedContent = export(scene.graph);
			files.set(fileName, exportedContent);
		}

		return files;
	}

	public static function loadScene(dataOrPath:String):GraphData {
		var data:String;

		#if nodejs
		data = Fs.readFileSync(dataOrPath, "utf8");
		#elseif js
		data = dataOrPath;
		#else
		data = File.getContent(dataOrPath);
		#end

		return deserialize(data);
	}

	public static function loadWorkspace(dataOrPath:String):Workspace {
		var dataStr:String;

		#if nodejs
		dataStr = Fs.readFileSync(dataOrPath, "utf8");
		#elseif js
		dataStr = dataOrPath;
		#else
		dataStr = File.getContent(dataOrPath);
		#end

		var rawData:data.WorkspaceData = Json.parse(dataStr);

		// build the actual runtime Workspace object instance
		var workspace = new Workspace(rawData.name);
		workspace.activeSceneId = rawData.activeSceneId;
		workspace.schemas = rawData.schemas != null ? rawData.schemas : [];

		if (rawData.scenes != null) {
			for (scene in rawData.scenes) {
				workspace.addScene(scene);
			}
		}

		return workspace;
	}
}
