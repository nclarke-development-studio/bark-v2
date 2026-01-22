package ui.nodes;

import data.PortData.PortDirection;
import haxe.ui.util.GUID;
import data.NodeData;

class NodeFactory {
	public static function createNode(type:String, x:Float, y:Float, ?id:String):NodeData {
		var nodeID = id != null ? id : GUID.uuid();
		switch type {
			default:
				return {
					id: nodeID,
					type: type,
					x: x,
					y: y,
					ports: [
						{
							id: GUID.uuid(),
							name: 'mainSource',
							direction: PortDirection.Output,
							isMain: false
						},
						{
							id: GUID.uuid(),
							name: 'mainSource',
							direction: PortDirection.Output,
							isMain: false
						}
					],
					fields: [],
				}
			case "source":
				return {
					id: nodeID,
					type: type,
					x: x,
					y: y,
					ports: [
						{
							id: GUID.uuid(),
							name: 'mainSource',
							direction: PortDirection.Output,
							isMain: false
						}
					],
					fields: [],
				}
			case "sink":
				return {
					id: nodeID,
					type: type,
					x: x,
					y: y,
					ports: [
						{
							id: GUID.uuid(),
							name: 'mainTarget',
							direction: PortDirection.Input,
							isMain: false
						}
					],
					fields: [],
				}
		}
	}
}
