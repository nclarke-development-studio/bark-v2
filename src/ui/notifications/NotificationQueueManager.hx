package ui.notifications;

import haxe.ui.notifications.NotificationManager;
import haxe.ui.notifications.NotificationData.NotificationActionData;
import haxe.ui.events.NotificationEvent;

class NotificationQueueManager {
	public static var instance:NotificationQueueManager = new NotificationQueueManager();

	private var queue:Array<Dynamic> = [];
	private var isShowing:Bool = false;

	public function new() {}

	/**
	 * Add a notification to the queue
	 * @param notificationData The notification info (title, body, actions)
	 * @param callback Optional callback for event-driven actions
	 */
	public function addNotification(notificationData:Dynamic, callback:Dynamic = null):Void {
		queue.push({data: notificationData, callback: callback});
		showNext();
	}

	private function showNext():Void {
		if (isShowing || queue.length == 0)
			return;

		isShowing = true;
		var item = queue.shift();
		var data = item.data;
		var callback = item.callback;

		// Wrap callback if provided
		if (callback != null && data.actions != null) {
			var actions:Array<Dynamic> = cast data.actions;
			for (action in actions) {
				var originalCallback = action.callback;
				action.callback = function(actionData:haxe.ui.notifications.NotificationData.NotificationActionData):Bool {
					callback(actionData);
					if (originalCallback != null)
						return originalCallback(actionData);
					return true;
				}
			}
		}

		NotificationManager.instance.addNotification(data);

		// Listen for dismissal to show the next
		NotificationManager.instance.registerEvent(NotificationEvent.HIDDEN, function(_) {
			isShowing = false;
			showNext();
		});
	}
}
