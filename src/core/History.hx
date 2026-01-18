package core;

import core.commands.ICommand;

class History {
	var undoStack:Array<ICommand> = [];
	var redoStack:Array<ICommand> = [];

	public function new() {}

	public function execute(cmd:ICommand) {
		cmd.execute();
		undoStack.push(cmd);
		redoStack = [];
	}

	public function undo() {
		if (undoStack.length > 0) {
			var c = undoStack.pop();
			c.undo();
			redoStack.push(c);
		}
	}

	public function redo() {
		if (redoStack.length > 0) {
			var c = redoStack.pop();
			c.execute();
			undoStack.push(c);
		}
	}

	public function clear(){
		undoStack = [];
		redoStack = [];
	}
}
