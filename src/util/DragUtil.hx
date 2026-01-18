// util for dragging in a scaled container
// Note: in order to use "draggable" on any component, the haxeui flag "-D haxeui-allow-drag-any-component" must be set.
//   setting this flag will add an "implements Draggable" on the core haxeui Component class
// ie: lime test hl -D hax...

// the above isn't needed for this project but may be useful later...
package util;

import haxe.ui.core.Component;
import haxe.ui.events.MouseEvent;
import haxe.ui.geom.Rectangle;
import haxe.ui.core.Screen;

class DragUtil {
	public static function makeScaleAwareDraggable(comp:Component, getZoom:() -> Float, dragBounds:Rectangle = null,
			onDrag:(Float, Float) -> Void = null):Void {
		var dragging = false;

		var startMouseX:Float = 0;
		var startMouseY:Float = 0;

		var startX:Float = 0;
		var startY:Float = 0;

		// handler references (must be vars!)
		var onGlobalMove:MouseEvent->Void = null;
		var onGlobalUp:MouseEvent->Void = null;

		comp.registerEvent(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
			dragging = true;

			startMouseX = e.screenX;
			startMouseY = e.screenY;

			startX = comp.left;
			startY = comp.top;

			onGlobalMove = function(e:MouseEvent) {
				if (!dragging)
					return;

				var zoom = getZoom();

				var dx = e.screenX - startMouseX;
				var dy = e.screenY - startMouseY;

				var worldX = startX + dx / zoom;
				var worldY = startY + dy / zoom;

				if (dragBounds != null) {
					worldX = clamp(worldX, dragBounds.left, dragBounds.right - comp.width);
					worldY = clamp(worldY, dragBounds.top, dragBounds.bottom - comp.height);
				}

				comp.left = worldX;
				comp.top = worldY;

				if (onDrag != null) {
					onDrag(worldX, worldY);
				}
			};

			onGlobalUp = function(_:MouseEvent) {
				dragging = false;

				Screen.instance.unregisterEvent(MouseEvent.MOUSE_MOVE, onGlobalMove);
				Screen.instance.unregisterEvent(MouseEvent.MOUSE_UP, onGlobalUp);
			};

			Screen.instance.registerEvent(MouseEvent.MOUSE_MOVE, onGlobalMove);
			Screen.instance.registerEvent(MouseEvent.MOUSE_UP, onGlobalUp);

			e.cancel();
		});
	}

	private static inline function clamp(v:Float, min:Float, max:Float):Float {
		return v < min ? min : (v > max ? max : v);
	}
}
