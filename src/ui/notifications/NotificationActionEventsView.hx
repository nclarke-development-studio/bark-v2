package ui.notifications;

import haxe.ui.containers.VBox;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.notifications.NotificationData.NotificationActionData;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.NotificationEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/views/notification-action-events.xml"))
class NotificationActionEventsView extends VBox {
	// Event-driven button click
	@:bind(actionNotificationEventButton, MouseEvent.CLICK)
	private function onActionNotificationEvents(_:MouseEvent) {
		actionNotificationEventLabel.text = "";
		NotificationManager.instance.addNotification({
			title: "Notification With Actions",
			body: "This notification has some actions attached to it. It will not expire automatically.",
			actions: [{text: "Foo"}, {text: "Bar"}]
		});
	}

	// Listen for actions on the NotificationManager

	@:bind(NotificationManager.instance, NotificationEvent.ACTION)
	private function onNotificationManagerAction(event:NotificationEvent) {
		var actionData = event.data;
		actionNotificationEventLabel.text = "You chose " + actionData.text + "!";
	}

	// Callback-driven button click

	@:bind(actionNotificationCallbackButton, MouseEvent.CLICK)
	private function onActionNotificationCallback(_:MouseEvent) {
		actionNotificationCallbackLabel.text = "";
		NotificationManager.instance.addNotification({
			title: "Notification With Actions",
			body: "This notification has callback-based actions. It will not expire automatically.",
			actions: [
				{text: "Foo", callback: onNotificationActionCallback},
				{text: "Bar", callback: onNotificationActionCallback}
			]
		});
	}

	// Callback for actionable notification
	private function onNotificationActionCallback(actionData:NotificationActionData):Bool {
		actionNotificationCallbackLabel.text = "You chose " + actionData.text + "!";
		return true; // return true to close the notification after action
	}
}
/*  NotificationManager.instance.addNotification({
		title: "Custom Styled Notification",
		body: "This notification has has been styled by css",
		styleNames: "custom-notification"
	});
 */
