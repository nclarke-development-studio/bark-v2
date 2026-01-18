package ui.menus;

import ui.nodes.NodeView;
import haxe.ui.containers.menus.Menu;
import haxe.ui.containers.menus.MenuItem;

class NodeContextMenu extends Menu {

    public function new(node:NodeView, controller:EditorController) {
        super();

        var deleteItem = new MenuItem();
        deleteItem.text = "Delete Node";
        deleteItem.onClick = _ -> {
            controller.deleteNode(node);
        };
        addComponent(deleteItem);

        var duplicateItem = new MenuItem();
        duplicateItem.text = "Duplicate Node";
        duplicateItem.onClick = _ -> {
            controller.duplicateNode(node);
        };
        addComponent(duplicateItem);
    }
}