package data;

enum abstract PortDirection(String) {
    var Input = "input";
    var Output = "output";
}

typedef PortData = {
    var id:String;
    var name:String;
	var isMain: Bool;
    var direction:PortDirection;
}