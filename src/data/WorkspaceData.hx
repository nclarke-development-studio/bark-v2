package data;

import data.NodeData.NodeGroupSchema;

typedef WorkspaceData = {
	var name:String;
	var scenes:Array<SceneData>;
	var activeSceneId:String;
	var schemas:Array<NodeGroupSchema>;
}
