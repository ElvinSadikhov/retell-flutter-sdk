/// Base class for all call-related events.
/// 
/// All events in the system must extend this class to ensure proper type safety
/// and event handling throughout the application.
abstract class CallEvent {
  /// The raw event data received from the server
  final Map<String, dynamic> data;

  /// Creates a new call event with the given [data].
  const CallEvent(this.data);
}

/// Event containing metadata information about the call.
/// 
/// This event typically includes information about the call context,
/// participant information, or other metadata that might be useful
/// for call management.
class MetadataEvent extends CallEvent {
  /// Creates a new metadata event with the given [data].
  const MetadataEvent(super.data);
}

/// Event representing general updates during the call.
/// 
/// These updates can include changes in call status, quality,
/// or other general information that doesn't fit into more specific event types.
class UpdateEvent extends CallEvent {
  /// Creates a new update event with the given [data].
  const UpdateEvent(super.data);
}

/// Event representing a transition between conversation nodes.
/// 
/// This event is triggered when the conversation moves from one logical
/// section to another, typically indicating a change in conversation context
/// or topic.
class NodeTransitionEvent extends CallEvent {
  /// Creates a new node transition event with the given [data].
  const NodeTransitionEvent(super.data);
}

/// Event for capturing unhandled or unknown event types.
/// 
/// This event is used as a fallback when an event type is received
/// that doesn't match any of the known event types.
class UnhandledEvent extends CallEvent {
  /// The type of the unhandled event
  final String eventType;

  /// Creates a new unhandled event with the given [eventType] and [data].
  const UnhandledEvent(this.eventType, Map<String, dynamic> data) : super(data);
}