import 'javascript_message.dart';

final RegExp _validChannelNames = RegExp('^[a-zA-Z_][a-zA-Z0-9]*\$');

/// Describes the parameters necessary for registering a JavaScript channel.
/// A named channel for receiving messaged from JavaScript code running inside a web view.
class JavascriptChannel {
  /// Creates a new [JavaScriptChannel] object.
  ///
  /// The parameters `name` is optional and `onMessageReceived` must not be null.
  JavascriptChannel({
    this.name = "",
    required this.onMessageReceived,
  }) : assert(_validChannelNames.hasMatch(name));

  /// The channel's name.
  ///
  /// Passing this channel object as part of a [WebView.javascriptChannels] adds a channel object to
  /// the Javascript window object's property named `name`.
  ///
  /// The name must start with a letter or underscore(_), followed by any combination of those
  /// characters plus digits.
  ///
  /// Note that any JavaScript existing `window` property with this name will be overriden.
  ///
  /// The name that identifies the JavaScript channel.
  /// See also [WebView.javascriptChannels] for more details on the channel registration mechanism.
  final String name;

  /// The callback method that is invoked when a [JavaScriptMessage] is
  /// received.
  /// A callback that's invoked when a message is received through the channel.
  final JavascriptMessageHandler onMessageReceived;
}

/// Callback type for handling messages sent from Javascript running in a web view.
typedef JavascriptMessageHandler = void Function(JavaScriptMessage message);
