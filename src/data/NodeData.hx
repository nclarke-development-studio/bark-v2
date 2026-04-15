package data;

typedef NodeField = {
	var type:String; // "string", "number", "text", "boolean", "data"
	var key:String;
	var value:Dynamic; // actual value for string/number/text/boolean, null for port
	var portId:Null<String>; // only set if type == "data"
}

typedef NodeData = {
	var id:String;
	var type:String;
	var x:Float;
	var y:Float;
	var ports:Array<PortData>;
	var fields:Array<NodeField>;
}

typedef SchemaField = {
	var key:String;
	var type:String; // "string" | "text" | "data"
	var value:Dynamic;
}

typedef SchemaNode = {
	var name:String;
	var type:String; // "base", "source", etc
	var color:String;
	var position:Array<Float>; // [x, y]
	var ?fields:Array<SchemaField>;
	var ?ports:Array<PortData>;
}

typedef SchemaEdge = {
	var fromHandle:String;
	var toHandle:String;
	var from:Int;
	var to:Int;
	var ?fields:Array<SchemaField>;
}

typedef NodeGroupSchema = {
	var name:String;
	var color:String;
	var nodes:Array<SchemaNode>;
	var edges:Array<SchemaEdge>;
}
