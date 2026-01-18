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
