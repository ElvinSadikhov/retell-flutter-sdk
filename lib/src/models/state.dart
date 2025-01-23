/// Represents the possible connection states of a call.
enum CallConnectionState {
  /// The client is not connected to any call
  disconnected,
  
  /// The client is in the process of establishing a connection
  connecting,
  
  /// The client is successfully connected to a call
  connected,
}

/// Represents whose turn it is to speak in the conversation.
enum TurnState {
  /// It's the user's turn to speak
  user,
  
  /// It's the agent's turn to speak
  agent,
} 