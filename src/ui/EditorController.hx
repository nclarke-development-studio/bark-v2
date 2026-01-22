// package ui;

// import ui.toolbar.Toolbar;
// import util.WorkspaceUtils;
// import ui.palette.Palette;
// import data.WorkspaceData;
// import core.Workspace;
// import data.SceneData;
// import data.NodeData;
// import haxe.ui.util.GUID;
// import ui.canvas.NodeCanvas;
// import ui.nodes.NodeView;
// import core.Graph;
// import core.History;
// import core.GraphSerializer;
// import core.commands.*;
// import data.PortData;
// import data.ConnectionData;

// class EditorController {
// 	public var graph:Graph; // active scene graph
// 	public var history:History; // active scene history
// 	public var palette:Palette;
// 	public var toolbar:Toolbar;
// 	public var workspace:Workspace;

// 	public function new(canvas:NodeCanvas, ?p:Palette, ?t:Toolbar) {
// 		if (p != null) {
// 			this.palette = p;
// 			palette.controller = this;
// 		}

// 		if (t != null) {
// 			this.toolbar = t;
// 			toolbar.controller = this;
// 		}

// 		graph = new Graph();
// 		history = new History();

// 		workspace = new Workspace('default');
// 	}

// 	// ==========================================================
// 	// NODE OPERATIONS
// 	// ==========================================================

// 	public function createNodeAt(x:Float, y:Float, ?d:NodeData):AddNodeCommand {
// 		var nodeData = {
// 			id: GUID.uuid(),
// 			type: "Default",
// 			x: x,
// 			y: y,
// 			ports: [],
// 			fields: [],
// 		};

// 		var cmd = new AddNodeCommand(graph, d != null ? d : nodeData);

// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	public function addNode(d:NodeData):AddNodeCommand {
// 		var cmd = new AddNodeCommand(graph, d);
// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	public function deleteNode(nodeView:NodeView):RemoveNodeCommand {
// 		var cmd = new RemoveNodeCommand(graph, nodeView.data);
// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	public function duplicateNode(nodeView:NodeView):AddNodeCommand {
// 		var newPorts = nodeView.data.ports.map(p -> {
// 			return {
// 				id: GUID.uuid(),
// 				name: p.name,
// 				direction: p.direction,
// 				isMain: p.isMain
// 			};
// 		});

// 		// TODO: Deep copy fields

// 		var copyData = {
// 			id: GUID.uuid(),
// 			type: nodeView.data.type,
// 			x: nodeView.data.x + 20,
// 			y: nodeView.data.y + 20,
// 			ports: newPorts,
// 			fields: nodeView.data.fields,
// 		};

// 		var cmd = new AddNodeCommand(graph, copyData);
// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	public function addPortToNode(nodeView:NodeView, name:String = "Extra", direction:PortDirection = PortDirection.Output) {
// 		var id = GUID.uuid();
// 		var portData:PortData = {
// 			id: id,
// 			name: name,
// 			direction: direction,
// 			isMain: false,
// 		};

// 		var cmd = new AddPortCommand(nodeView.data, portData);
// 		// nodeView.addPort(id, false, direction);

// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	// ==========================================================
// 	// CONNECTIONS
// 	// ==========================================================

// 	public function connectPorts(fromNode:NodeData, fromPort:PortData, toNode:NodeData, toPort:PortData) {
// 		var conn = {
// 			fromPort: fromPort.id,
// 			toPort: toPort.id,
// 			fromNode: fromNode.id,
// 			toNode: toNode.id,
// 			id: GUID.uuid(),
// 		}
// 		var cmd = new ConnectPortsCommand(graph, conn);
// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	public function removeConnection(conn:ConnectionData) {
// 		var cmd = new RemoveConnectionCommand(graph, conn);
// 		history.execute(cmd);
// 		canvas.rebuildUI();
// 		return cmd;
// 	}

// 	// ==========================================================
// 	// UNDO / REDO
// 	// ==========================================================

// 	public function undo() {
// 		history.undo();
// 		canvas.rebuildUI();
// 	}

// 	public function execute() {
// 		history.redo();
// 		canvas.rebuildUI();
// 	}

// 	// ==========================================================
// 	// SAVE / LOAD
// 	// ==========================================================

// 	public function newWorkspace(name:String) {
// 		workspace = new Workspace(name);
// 		createScene("default");
// 		switchScene("default");
// 		if (palette != null) {
// 			palette.rebuildScenes();
// 		}
// 	}

// 	public function saveWorkspace(path:String = "workspace.json") {
// 		var data:WorkspaceData = {
// 			scenes: [for (s in workspace.scenes) s],
// 			activeSceneId: workspace.activeSceneId
// 		};
// 		// GraphSerializer.save(path, data);
// 	}

// 	public function loadWorkspace(path:String = "workspace.json") {
// 		// var data:WorkspaceData = GraphSerializer.load(path);

// 		// workspace = new Workspace();
// 		// for (scene in data.scenes)
// 		// 	workspace.addScene(scene);

// 		// switchScene(data.activeSceneId);
// 		if (palette != null)
// 			palette.rebuildScenes();
// 	}

// 	public function renameWorkspace(newName:String) {
// 		workspace.name = newName;
// 	}

// 	public function renameScene(oldId:String, newId:String):Bool {
// 		if (oldId == newId) {
// 			return false;
// 		}

// 		// prevent collisions
// 		if (workspace.scenes.exists(newId)) {
// 			return false;
// 		}

// 		var scene = workspace.scenes.get(oldId);
// 		if (scene == null) {
// 			return false;
// 		}

// 		// remove old entry
// 		workspace.scenes.remove(oldId);

// 		// update scene id
// 		scene.id = newId;

// 		// reinsert under new key
// 		workspace.scenes.set(newId, scene);

// 		// update active scene if needed
// 		if (workspace.activeSceneId == oldId) {
// 			workspace.activeSceneId = newId;
// 		}

// 		if (palette != null)
// 			palette.rebuildScenes();

// 		return true;
// 	}

// 	public function saveScene(path:String = "graph.json") {
// 		GraphSerializer.save(path, graph.data);
// 	}

// 	public function loadScene(path:String = "graph.json") {
// 		graph.data = GraphSerializer.load(path);
// 		history.clear();
// 		canvas.rebuildUI();
// 	}

// 	public function createScene(id:String) {
// 		var scene:SceneData = {
// 			id: id,
// 			graph: {
// 				nodes: [],
// 				connections: []
// 			}
// 		};
// 		workspace.addScene(scene);

// 		if (palette != null)
// 			palette.rebuildScenes();
// 	}

// 	public function switchScene(id:String) {
// 		var scene = workspace.scenes.get(id);
// 		if (scene == null) {
// 			return;
// 		}

// 		workspace.activeSceneId = id;

// 		graph = new Graph(scene.graph);
// 		history = new History();

// 		if (palette != null)
// 			palette.rebuildScenes();

// 		canvas.rebuildUI();
// 	}

// 	function generateSceneCopyName(base:String):String {
// 		var i = 1;
// 		var name = base + "_copy";
// 		while (workspace.scenes.exists(name)) {
// 			name = base + "_copy" + i++;
// 		}
// 		return name;
// 	}

// 	public function duplicateScene():Void {
// 		var srcId = workspace.activeSceneId;
// 		var srcScene = workspace.scenes.get(srcId);

// 		var newId = generateSceneCopyName(srcId);
// 		var clonedGraph = WorkspaceUtils.cloneGraph(srcScene.graph);

// 		workspace.scenes.set(newId, {
// 			id: newId,
// 			graph: clonedGraph
// 		});

// 		if (palette != null)
// 			palette.rebuildScenes();

// 		switchScene(newId);
// 	}

// 	public function deleteScene(id:String) {
// 		workspace.removeScene(id);
// 		switchScene(workspace.activeSceneId);

// 		if (palette != null)
// 			palette.rebuildScenes();
// 	}

// 	public function createSchema(name:String, nodes:Array<NodeData>, allConnections:Array<ConnectionData>) {
// 		return WorkspaceUtils.encodeSchema(name, '', nodes, allConnections);
// 	}

// 	// TODO: actual clipboard paste
// 	// Clipboard.setText(haxe.Json.stringify(schema));
// 	// pasteSchema(Json.parse(Clipboard.getText()), mouseX, mouseY);
// 	public function pasteSchema(schema:NodeGroupSchema, x:Float, y:Float) {
// 		var decoded = WorkspaceUtils.decodeSchema(schema, x, y);
// 		var nodes = decoded.nodes;
// 		var connections = decoded.connections;

// 		for (n in nodes)
// 			history.execute(new AddNodeCommand(graph, n));
// 		for (c in connections) {
// 			history.execute(new ConnectPortsCommand(graph, c));
// 		}

// 		canvas.rebuildUI();

// 		// select the pasted nodes afterwards
// 		canvas.clearSelection();
// 		for (n in nodes) {
// 			var view = canvas.getNodeView(n.id);
// 			if (view != null) {
// 				canvas.selectNode(view);
// 			}
// 		}
// 	}

// 	public function saveSelected(n:String) {
// 		var nodeData = canvas.selectedNodes.map(node -> node.data);
// 		return WorkspaceUtils.encodeSchema(n, '', nodeData, graph.data.connections);
// 	}
// }
