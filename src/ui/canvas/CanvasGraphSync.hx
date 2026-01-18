package ui.canvas;

import haxe.ds.StringMap;
import ui.nodes.NodeView;
import ui.connections.ConnectionView;
import util.ArrayUtils;

class CanvasGraphSync {
	private var canvas:NodeCanvas;

	public function new(canvas:NodeCanvas) {
		this.canvas = canvas;
	}

	/**
	 * Synchronize node views with the graph data
	 */
	public function syncNodes():Void {
		var dataNodeMap = new StringMap<Bool>();
		for (nd in canvas.controller.graph.data.nodes) {
			dataNodeMap.set(nd.id, true);
		}

		// Remove deleted nodeViews
		var i = canvas.nodes.length - 1;
		while (i >= 0) {
			var nv = canvas.nodes[i];
			if (!dataNodeMap.exists(nv.data.id)) {
				canvas.nodeLayer.removeComponent(nv);
				canvas.nodes.splice(i, 1);
			}
			i--;
		}

		// Map remaining nodeViews for reuse
		var viewMap = new StringMap<NodeView>();
		for (nv in canvas.nodes)
			viewMap.set(nv.data.id, nv);

		// Update or create nodeViews
		for (nodeData in canvas.controller.graph.data.nodes) {
			var nv = viewMap.exists(nodeData.id) ? viewMap.get(nodeData.id) : null;

			if (nv == null) {
				nv = new NodeView(nodeData, canvas.controller);

				// make draggable with scale-aware bounds
				util.DragUtil.makeScaleAwareDraggable(nv, () -> canvas.zoom, canvas.contentBounds, function(x, y) {
					nv.data.x = x;
					nv.data.y = y;
					canvas.refreshConnections(nv);
					canvas.updateContentBounds();
				});

				canvas.nodes.push(nv);
				canvas.nodeLayer.addComponent(nv);
			}

			nv.left = nodeData.x;
			nv.top = nodeData.y;
			nv.updatePorts();
		}
	}

	/**
	 * Synchronize connection views with graph data
	 */
	public function syncConnections():Void {
		// Reset edge maps
		canvas.edgesIntoMap = new Map();
		canvas.edgesOutMap = new Map();

		// Map existing connection views
		var viewMap = new StringMap<ConnectionView>();
		for (cv in canvas.connections)
			viewMap.set(cv.dataKey(), cv);

		var validKeys = new StringMap<Bool>();

		for (connData in canvas.controller.graph.data.connections) {
			var key = connData.fromPort + "->" + connData.toPort;
			validKeys.set(key, true);

			var cv = viewMap.exists(key) ? viewMap.get(key) : null;

			if (cv == null) {
				var fromNode = ArrayUtils.find(canvas.nodes, n -> n.hasPort(connData.fromPort));
				var toNode = ArrayUtils.find(canvas.nodes, n -> n.hasPort(connData.toPort));

				if (fromNode != null && toNode != null) {
					cv = new ConnectionView(fromNode, toNode, connData);
					canvas.connections.push(cv);
					canvas.edgeLayer.addComponent(cv);
				}
			}

			if (cv != null) {
				// register edges
				if (!canvas.edgesOutMap.exists(cv.fromNode.data.id))
					canvas.edgesOutMap[cv.fromNode.data.id] = [];
				canvas.edgesOutMap[cv.fromNode.data.id].push(cv);

				if (!canvas.edgesIntoMap.exists(cv.toNode.data.id))
					canvas.edgesIntoMap[cv.toNode.data.id] = [];
				canvas.edgesIntoMap[cv.toNode.data.id].push(cv);
			}
		}

		// Remove deleted connections
		var i = canvas.connections.length - 1;
		while (i >= 0) {
			var cv = canvas.connections[i];
			if (!validKeys.exists(cv.dataKey())) {
				canvas.edgeLayer.removeComponent(cv);
				canvas.connections.splice(i, 1);
			}
			i--;
		}

		canvas.refreshConnections();
	}

	/**
	 * Remove invalid nodes from the selection list
	 */
	public function cleanupSelection():Void {
		var validNodeIds = new StringMap<Bool>();
		for (n in canvas.nodes)
			validNodeIds.set(n.data.id, true);

		var i = canvas.selectedNodes.length - 1;
		while (i >= 0) {
			var n = canvas.selectedNodes[i];
			if (!validNodeIds.exists(n.data.id)) {
				n.setSelected(false);
				canvas.selectedNodes.splice(i, 1);
			}
			i--;
		}
	}

	/**
	 * Rebuild the UI incrementally (nodes + connections + selection)
	 */
	public function rebuildUI():Void {
		syncNodes();
		syncConnections();
		cleanupSelection();
		canvas.updateContentBounds();
	}
}
