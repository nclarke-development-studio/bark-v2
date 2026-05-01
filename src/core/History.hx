package core;

import core.commands.ICommand;

class History {
	var undoStack:Array<ICommand> = [];
	var redoStack:Array<ICommand> = [];
	var maxSize:Int;

	/**
	 * @param maxSize The maximum number of commands to keep in the undo history.
	 */
	public function new(maxSize = 20) {
		this.maxSize = maxSize;
	}

	public function execute(cmd:ICommand) {
		cmd.execute();
		addToUndoStack(cmd);
		redoStack = [];
	}

	public function undo() {
		if (undoStack.length > 0) {
			var c = undoStack.pop();
			c.undo();
			redoStack.push(c);
			if (redoStack.length > maxSize) {
				redoStack.shift();
			}
		}
	}

	public function redo() {
		if (redoStack.length > 0) {
			var c = redoStack.pop();
			c.execute();
			addToUndoStack(c);
		}
	}

	public function clear() {
		undoStack = [];
		redoStack = [];
	}

	private function addToUndoStack(cmd:ICommand) {
		undoStack.push(cmd);
		if (undoStack.length > maxSize) {
			undoStack.shift(); // Removes the oldest command (index 0)
		}
	}
}
