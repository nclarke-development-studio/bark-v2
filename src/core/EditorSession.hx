package core;

import ui.palette.schema.SchemaEditor;
import core.commands.RemoveNodesCommand;
import haxe.Json;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.Dialogs;
import util.WorkspaceUtils;
import util.WorkspaceUtils;
import data.PortData;
import core.commands.RemoveConnectionCommand;
import core.commands.ConnectPortsCommand;
import haxe.ui.util.GUID;
import core.commands.RemoveNodeCommand;
// import data.WorkspaceData;
import data.SceneData;
import core.commands.AddNodeCommand;
import data.NodeData;
import data.ConnectionData;
#if !js
import sys.io.File;
#end
#if js
import js.Browser;
#end
#if nodejs
import js.node.Fs;
#end

interface IEditorSession {
	public var graph(default, null):Graph;
	public var history(default, null):History;
	public var workspace(default, null):Workspace;

	function addNode(d:NodeData):Void;
	function addNodes(d:Array<NodeData>):Void;
	function removeNode(id:String):Void;
	function removeNodes(ids:Array<String>):Void;
	function duplicateNode(d:NodeData):Void;

	function connectPorts(n1:NodeData, p1:PortData, n2:NodeData, p2:PortData):ConnectionData;
	function addConnection(c:ConnectionData):Void;
	function removeConnection(c:ConnectionData):Void;

	function undo():Void;
	function redo():Void;

	function createScene(id:String):Void;
	function switchScene(id:String):Void;
	function duplicateScene(id:String):Void;
	function renameScene(oldId:String, newId:String):Bool;
	function loadScene():Void;
	function deleteScene(id:String):Void;
	function saveScene():Void;
	function exportScene():Void;

	function getWorkspace():Workspace;
	function getActiveScene():SceneData;
	function getWorkspaceScenes():Array<SceneData>;
	function getWorkspaceName():String;
	function createWorkspace(id:String):Void;
	function renameWorkspace(name:String):Void;
	function loadWorkspace():Void;
	function saveWorkspace():Void;
	function exportWorkspace():Void;

	function addSchemaToWorkspace(n:NodeGroupSchema):Void;
	function removeSchemaFromWorkspace(id:String):Void;

	function enterSchemaEditMode():Void;
	function exitSchemaEditMode():Void;
}

enum EditorChange {
	GraphChanged;
	WorkspaceChanged;
}

class EditorSession implements IEditorSession {
	public var graph:Graph;
	public var history:History;
	public var workspace:Workspace;

	// TODO:
	// file path for the workspace
	public var filePath:String = null;

	public var onChanged:(EditorChange) -> Void;

	public function new() {
		graph = new Graph();
		history = new History();
		workspace = new Workspace("default");
	}

	function notify(change:EditorChange) {
		if (onChanged != null)
			onChanged(change);
	}

	public function undo() {
		history.undo();
		notify(GraphChanged);
	}

	public function redo() {
		history.redo();
		notify(GraphChanged);
	}

	// nodes ===================================================

	public function addNode(d:NodeData) {
		history.execute(new AddNodeCommand(graph, d));
		notify(GraphChanged);
	}

	public function addNodes(d:Array<NodeData>) {
		for (node in d) {
			history.execute(new AddNodeCommand(graph, node));
			notify(GraphChanged);
		}
	}

	public function createNodes(s:NodeGroupSchema, x, y):Array<NodeData> {
		var decoded = WorkspaceUtils.decodeSchema(s, x, y);
		var nodes = decoded.nodes;
		var connections = decoded.connections;

		for (n in nodes)
			history.execute(new AddNodeCommand(graph, n));
		for (c in connections) {
			history.execute(new ConnectPortsCommand(graph, c));
		}

		notify(GraphChanged);
		return nodes;
	}

	public function removeNode(id:String) {
		var node = graph.getNode(id);
		if (node == null) {
			return;
		}
		var cmd = new RemoveNodeCommand(graph, node);
		history.execute(cmd);
		notify(GraphChanged);
	}

	// bulk node removal
	public function removeNodes(ids:Array<String>) {
		var nodes = [];
		for (id in ids) {
			var node = graph.getNode(id);
			if (node == null) {
				continue;
			}
			nodes.push(node);
		}
		var cmd = new RemoveNodesCommand(graph, nodes);
		history.execute(cmd);
		notify(GraphChanged);
	}

	public function duplicateNode(d:NodeData) {
		var newPorts = d.ports.map(p -> {
			return {
				id: GUID.uuid(),
				name: p.name,
				direction: p.direction,
				isMain: p.isMain
			};
		});

		// TODO: Deep copy fields

		var copyData = {
			id: GUID.uuid(),
			type: d.type,
			x: d.x + 20,
			y: d.y + 20,
			ports: newPorts,
			fields: d.fields,
		};

		var cmd = new AddNodeCommand(graph, copyData);
		history.execute(cmd);
		notify(GraphChanged);
	}

	// connections ===================================================

	public function connectPorts(n1:NodeData, p1:Dynamic, n2:NodeData, p2:Dynamic):ConnectionData {
		var conn = {
			fromNode: n1.id,
			fromPort: p1.id,
			toNode: n2.id,
			toPort: p2.id,
			id: GUID.uuid(),
			fields: [],
		}
		addConnection(conn);
		return conn;
	}

	public function addConnection(c:ConnectionData) {
		var cmd = new ConnectPortsCommand(graph, c);
		history.execute(cmd);
		notify(GraphChanged);
	}

	public function removeConnection(c:ConnectionData) {
		var cmd = new RemoveConnectionCommand(graph, c);
		history.execute(cmd);
		notify(GraphChanged);
	}

	// scenes =======================================================

	public function createScene(id:String) {
		var scene:SceneData = {
			id: id,
			graph: {
				nodes: [],
				connections: []
			}
		};

		workspace.addScene(scene);

		notify(GraphChanged);
		notify(WorkspaceChanged);
	}

	public function switchScene(id:String) {
		var scene = workspace.scenes.get(id);
		if (scene == null) {
			return;
		}

		workspace.activeSceneId = id;

		graph = new Graph(scene.graph);
		history = new History();

		notify(GraphChanged);
		notify(WorkspaceChanged);
	}

	public function loadScene() {
		Dialogs.openFile(function(button, files) {
			if (button == DialogButton.OK && files.length > 0) {
				graph.data = GraphSerializer.loadScene(files[0].fullPath);
				history.clear();
				notify(GraphChanged);
				notify(WorkspaceChanged);
			}
		}, {
			readContents: true,
			title: "Open",
			readAsBinary: true,
			multiple: false,
			extensions: [{label: "Bark Dialogye Scene File", extension: "woof"}]
		});
	}

	public function saveScene() {
		var data = GraphSerializer.save(graph.data);

		Dialogs.saveFile(function(button, success, path) {
			if (button == DialogButton.OK && success && path != null) {
				// write data to the path the user actually chose
				#if nodejs
				Fs.writeFileSync(path, data);
				#elseif js
				// On web, saveFile usually triggers a browser download automatically
				// but if you need manual storage:
				Browser.window.localStorage.setItem(path, data);
				#else
				File.saveContent(path, data);
				#end

				trace("Scene saved to: " + path);
			}
		}, {
			name: '${workspace.activeSceneId}.woof',
			text: data,
			isBinary: false
		}, {
			// writeAsBinary: false,
			// extensions: [{label: "bark dialogue file", extension: "bark"}],
			// title: "save scene file"
			extensions: [{label: "Bark Scene", extension: "woof"}],
			title: "Save Scene"
		});
	}

	public function exportScene() {
		var data = GraphSerializer.export(graph.data);

		Dialogs.saveFile(function(button, success, path) {
			if (button == DialogButton.OK && success && path != null) {
				// write data to the path the user actually chose
				#if nodejs
				Fs.writeFileSync(path, data);
				#elseif js
				// On web, saveFile usually triggers a browser download automatically
				// but if you need manual storage:
				Browser.window.localStorage.setItem(path, data);
				#else
				File.saveContent(path, data);
				#end

				trace("Scene saved to: " + path);
			}
		}, {
			name: '${workspace.activeSceneId}.json',
			text: data,
			isBinary: false
		}, {
			// writeAsBinary: false,
			// extensions: [{label: "bark dialogue file", extension: "bark"}],
			// title: "save scene file"
			extensions: [{label: "JSON", extension: "json"}],
			title: "Export Scene"
		});
	}

	public function renameScene(oldId:String, newId:String):Bool {
		if (oldId == newId) {
			return false;
		}

		// prevent collisions
		if (workspace.scenes.exists(newId)) {
			return false;
		}

		var scene = workspace.scenes.get(oldId);
		if (scene == null) {
			return false;
		}

		workspace.scenes.remove(oldId);
		scene.id = newId;
		workspace.scenes.set(newId, scene);

		if (workspace.activeSceneId == oldId) {
			workspace.activeSceneId = newId;
		}

		notify(WorkspaceChanged);
		return true;
	}

	// workspace ==============================================

	public function createWorkspace(name:String) {
		filePath = null;
		workspace = new Workspace(name);
		createScene("default");
		switchScene("default");

		notify(WorkspaceChanged);
		notify(GraphChanged);
	}

	public function renameWorkspace(newName:String) {
		workspace.name = newName;
		notify(WorkspaceChanged);
	}

	public function loadWorkspace() {
		Dialogs.openFile(function(button, files) {
			if (button == DialogButton.OK && files.length > 0) {
				workspace = GraphSerializer.loadWorkspace(files[0].fullPath);

				filePath = files[0].fullPath;

				if (workspace.activeSceneId != null)
					switchScene(workspace.activeSceneId);

				history.clear();
				notify(WorkspaceChanged);
				notify(GraphChanged);
			}
		}, {extensions: [{label: "Bark Workspace", extension: "bark"}]});
	}

	public function saveWorkspace() {
		// Serialize the whole workspace object into one JSON string
		var data = GraphSerializer.serializeWorkspace(workspace);

		if (filePath != null) {
			#if nodejs
			Fs.writeFileSync(filePath, data);
			#elseif js
			Browser.window.localStorage.setItem(filePath, data);
			#else
			File.saveContent(filePath, data);
			#end

			trace("Workspace saved to: " + filePath);

			return;
		}

		Dialogs.saveFile(function(button, success, selectedPath) {
			if (button == DialogButton.OK && success && selectedPath != null) {
				filePath = selectedPath;
				#if nodejs
				Fs.writeFileSync(selectedPath, data);
				#elseif js
				Browser.window.localStorage.setItem(selectedPath, data);
				#else
				File.saveContent(selectedPath, data);
				#end

				trace("Workspace saved to: " + selectedPath);
			}
		}, {
			name: '${workspace.name}.bark',
			text: data,
			isBinary: false
		}, {
			extensions: [{label: "Bark Workspace", extension: "bark"}],
			title: "Save Workspace"
		});
	}

	public function saveAsWorkspace() {
		// Serialize the whole workspace object into one JSON string
		var data = GraphSerializer.serializeWorkspace(workspace);

		Dialogs.saveFile(function(button, success, selectedPath) {
			if (button == DialogButton.OK && success && selectedPath != null) {
				filePath = selectedPath;
				#if nodejs
				Fs.writeFileSync(selectedPath, data);
				#elseif js
				Browser.window.localStorage.setItem(selectedPath, data);
				#else
				File.saveContent(selectedPath, data);
				#end

				trace("Workspace saved to: " + selectedPath);
			}
		}, {
			name: '${workspace.name}.bark',
			text: data,
			isBinary: false
		}, {
			extensions: [{label: "Bark Workspace", extension: "bark"}],
			title: "Save Workspace"
		});
	}

	public function exportWorkspace() {
		var exportMap = GraphSerializer.getExportFiles(workspace);

		// Ask user where the main manifest file should go
		Dialogs.saveFile(function(button, success, path) {
			if (button == DialogButton.OK && success && path != null) {
				#if (sys || nodejs)
				var dir = haxe.io.Path.directory(path);

				for (fileName => content in exportMap) {
					var fullPath = haxe.io.Path.join([dir, fileName]);
					#if nodejs
					Fs.writeFileSync(fullPath, content);
					#else
					File.saveContent(fullPath, content);
					#end
				}

				var manifest = GraphSerializer.exportWorkspace(workspace);
				#if nodejs
				Fs.writeFileSync(path, manifest);
				#else
				File.saveContent(path, manifest);
				#end
				#end
			}
		}, {
			name: '${workspace.name}.json',
			text: "",
			isBinary: false
		}, {
			title: "Select Export Location (Manifest File)",
			extensions: [{label: "JSON Export", extension: "json"}]
		});
	}

	public function addSchemaToWorkspace(n:NodeGroupSchema) {
		// TODO: error check
		workspace.schemas.push(n);
		notify(WorkspaceChanged);
	}

	public function removeSchemaFromWorkspace(id:String) {
		workspace.schemas.filter(s -> s.name != id);
		notify(WorkspaceChanged);
	}

	public function duplicateScene(id:String) {
		var sourceScene = workspace.scenes.get(id);
		if (sourceScene == null)
			return;

		// deep copy using Json serialization
		var copyString = haxe.Json.stringify(sourceScene);
		var sceneCopy:SceneData = haxe.Json.parse(copyString);

		// unique ID (e.g., "SceneName_copy")
		var newId = id + "_copy";
		var counter = 1;
		while (workspace.scenes.exists(newId)) {
			newId = id + "_copy_" + counter;
			counter++;
		}

		sceneCopy.id = newId;
		workspace.addScene(sceneCopy);

		switchScene(newId);
		notify(WorkspaceChanged);
	}

	public function deleteScene(id:String) {
		workspace.removeScene(id);
		notify(WorkspaceChanged);
	}

	public function getWorkspace():Workspace {
		return workspace;
	}

	public function getWorkspaceScenes():Array<SceneData> {
		var out:Array<SceneData> = [];
		for (s in workspace.scenes) {
			out.push(s);
		}
		return out;
	}

	public function getWorkspaceName():String {
		return workspace.name;
	}

	public function getActiveScene():SceneData {
		return workspace.scenes[workspace.activeSceneId];
	}

	public function enterSchemaEditMode() {
		var dialog = new SchemaEditor(workspace, null, (schema) -> {
			addSchemaToWorkspace(schema);
		});
		dialog.showDialog();
	}

	public function exitSchemaEditMode() {}
}
