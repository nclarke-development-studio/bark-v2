package core.commands;

import ui.nodes.NodeView;

class MoveNodeCommand implements ICommand {
    var node:NodeView;
    var fromX:Float;
    var fromY:Float;
    var toX:Float;
    var toY:Float;

    public function undo() {
        node.left = fromX;
        node.top = fromY;
    }

    public function execute() {
        node.left = toX;
        node.top = toY;
    }
}