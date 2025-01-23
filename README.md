# Retell Flutter Package Source Code

This directory contains the core implementation of the Retell Flutter package.

## Directory Structure 

src/
├── models/ # Data models and state definitions
├── utils/ # Utility classes and helpers
└── retell_client.dart # Main client implementation


## Components

### Models (`models/`)

Contains all data models and state definitions used throughout the package:

#### `call_event.dart`
Defines the event system for call-related events:
- `CallEvent`: Base abstract class for all events
- `MetadataEvent`: Contains metadata information from the call
- `UpdateEvent`: Represents general updates during the call
- `NodeTransitionEvent`: Represents transitions between conversation nodes
- `UnhandledEvent`: Captures any unhandled event types

#### `call_states.dart`
Defines enums for various states:
- `CallConnectionState`: Represents connection states (disconnected, connecting, connected)
- `TurnState`: Manages conversation turns between user and agent

#### `start_call_config.dart`
Configuration class for initializing calls:
- `StartCallConfig`: Contains all necessary parameters to start a call
  - `accessToken`: Required authentication token
  - `sampleRate`: Optional audio sample rate
  - `captureDeviceId`: Optional audio capture device identifier
  - `playbackDeviceId`: Optional audio playback device identifier
  - `emitRawAudioSamples`: Flag for raw audio sample emission

### Utils (`utils/`)

Contains utility classes used throughout the package:

#### `logger.dart`
Implements a singleton logger for the package:
- `RetellLogger`: Handles all logging operations
  - Configurable logging enable/disable
  - Debug and error level logging
  - Prefixed logs with "[Retell]" for easy identification
  - Pretty printing with customizable format

### Main Client (`retell_client.dart`)

The core client implementation that handles all Retell.ai interactions:

#### Key Features:
- WebSocket connection management
- Audio stream handling
- Event processing and distribution
- State management (connection, turn states)
- Mute/unmute functionality

#### Main Components:
- State management using RxDart subjects
- Room management for LiveKit integration
- Event handling system
- Audio control methods

## Usage Flow

1. Create an instance of `RetellFlutterClient`
2. Initialize the client with desired logging configuration
3. Configure the call using `StartCallConfig`
4. Start the call and handle events/states through provided streams
5. Use control methods (mute/unmute) as needed
6. Properly dispose of the client when done

## Setup

### Android Permissions

Add the following permissions to your `android/app/src/main/AndroidManifest.xml` file inside the `<manifest>` tag:
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>

### iOS Permissions

Add the following keys to your `ios/Runner/Info.plist` file inside the `<dict>` tag:
    <key>NSMicrophoneUsageDescription</key>
    <string>Need microphone access for audio calls</string>

## Example Usage

final client = RetellFlutterClient();
// Initialize with logging
client.initialize(enableLogging: true);
// Configure and start call
final config = StartCallConfig(
accessToken: 'your_token_here',
emitRawAudioSamples: true,
);
await client.startCall(config);
// Listen to events
client.eventsStream.listen((event) {
if (event is MetadataEvent) {
// Handle metadata
}
});
// Clean up
client.dispose();

## Notes

- All components are designed to work together seamlessly
- The package uses RxDart for reactive programming
- LiveKit is used for real-time communication
- Proper initialization and disposal are crucial for memory management 