package ui.canvas;

import core.Graph;
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
	public function syncNodes(g:Graph):Void {
		var dataNodeMap = new StringMap<Bool>();
		for (nd in g.data.nodes) {
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
		for (nodeData in g.data.nodes) {
			var nv = viewMap.exists(nodeData.id) ? viewMap.get(nodeData.id) : null;

			if (nv == null) {
				nv = new NodeView(nodeData);

				nv.onNodeClicked = (n) -> {
					if (n.selected)
						canvas.selectNode(n);
					else
						canvas.deselectNode(n);
				}

				nv.onRequestContextMenu = (n, e) -> {
					if (canvas.onRequestNodeContextMenu != null) {
						canvas.onRequestNodeContextMenu(n, e);
					}
				}

				nv.onRemoveConnection = (c) -> {
					if (canvas.onRemoveConnection != null) {
						canvas.onRemoveConnection(c);
					}
				}

				nv.onConnectionStart = (pv, e) -> {
					canvas.beginConnection(pv, e);
				}

				nv.onConnectionFinish = (pv, e) -> {
					return canvas.finishConnection(pv);
				}

				// TODO: really don't like this
				nv.init();

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

	public function syncConnections(g:Graph):Void {
		canvas.edgesIntoMap = new Map();
		canvas.edgesOutMap = new Map();

		// Map existing connection views by connection id
		var viewMap = new StringMap<ConnectionView>();
		for (cv in canvas.connections)
			viewMap.set(cv.data.id, cv);

		var validIds = new StringMap<Bool>();

		for (connData in g.data.connections) {
			var id = connData.id;
			validIds.set(id, true);

			var cv = viewMap.exists(id) ? viewMap.get(id) : null;

			if (cv == null) {
				var fromNode = ArrayUtils.find(canvas.nodes, n -> n.hasPort(connData.fromPort));
				var toNode = ArrayUtils.find(canvas.nodes, n -> n.hasPort(connData.toPort));

				if (fromNode != null && toNode != null) {
					cv = new ConnectionView(fromNode, toNode, connData);
					canvas.connections.push(cv);
					canvas.edgeLayer.addComponent(cv);
				} else {}
			}

			if (cv != null) {
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
			if (!validIds.exists(cv.data.id)) {
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
	public function cleanupSelection(g:Graph):Void {
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
	public function rebuild(g:Graph):Void {
		syncNodes(g);
		syncConnections(g);
		cleanupSelection(g);
		canvas.updateContentBounds();
	}
}
