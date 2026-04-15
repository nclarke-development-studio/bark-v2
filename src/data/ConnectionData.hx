package data;

import data.NodeData.NodeField;

typedef ConnectionData = {
	var id:String;
	var fromNode:String;
	var toNode:String;
	var fromPort:String;
	var toPort:String;
	var fields: Array<NodeField>;
}
