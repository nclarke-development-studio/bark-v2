package core;

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

interface IEditorSession {
	public var graph(default, null):Graph;
	public var history(default, null):History;
	public var workspace(default, null):Workspace;

	function addNode(d:NodeData):Void;
	function removeNode(id:String):Void;
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
	function loadScene(path:String):Void;
	function deleteScene(path:String):Void;
	function saveScene(path:String = "graph.json"):Void;

	function getWorkspace():Workspace;
	function getActiveScene():SceneData;
	function getWorkspaceScenes():Array<SceneData>;
	function getWorkspaceName():String;
	function createWorkspace(id:String):Void;
	function renameWorkspace(name:String):Void;
	function loadWorkspace(path:String):Void;
	function saveWorkspace(path:String = "graph.json"):Void;

	function addNodeToWorkspace(n:NodeGroupSchema):Void;
	function removeNodeFromWorkspace(id:String):Void;
}

enum EditorChange {
	GraphChanged;
	WorkspaceChanged;
}

class EditorSession implements IEditorSession {
	public var graph:Graph;
	public var history:History;
	public var workspace:Workspace;

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

	public function loadScene(path:String) {
		graph.data = GraphSerializer.load(path);
		history.clear();
		notify(GraphChanged);
		notify(WorkspaceChanged);
	}

	public function saveScene(path:String = "graph.json") {
		GraphSerializer.save(path, graph.data);
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

	public function loadWorkspace(path:String) {
		// var data:WorkspaceData = GraphSerializer.load(path);

		// workspace = new Workspace();
		// for (scene in data.scenes)
		// 	workspace.addScene(scene);

		// switchScene(data.activeSceneId);
		notify(WorkspaceChanged);
		notify(GraphChanged);
	}

	public function saveWorkspace(?path:String) {
		// var data:WorkspaceData = {
		// 	scenes: [for (s in workspace.scenes) s],
		// 	activeSceneId: workspace.activeSceneId,
		// 	name:workspace.
		// };
		// GraphSerializer.save(path, data);
	}

	public function addNodeToWorkspace(n:NodeGroupSchema) {
		// TODO: error check
		workspace.schemas.push(n);
		notify(WorkspaceChanged);
	}

	public function removeNodeFromWorkspace(id:String) {
		workspace.schemas.filter(s -> s.name != id);
		notify(WorkspaceChanged);
	}

	public function duplicateScene(id:String) {
		notify(WorkspaceChanged);
	}

	public function deleteScene(path:String) {
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
}
