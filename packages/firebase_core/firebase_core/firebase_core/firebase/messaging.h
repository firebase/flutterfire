// Copyright 2016 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef FIREBASE_MESSAGING_SRC_INCLUDE_FIREBASE_MESSAGING_H_
#define FIREBASE_MESSAGING_SRC_INCLUDE_FIREBASE_MESSAGING_H_

#include <stdint.h>

#include <map>
#include <string>
#include <vector>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"

#if !defined(DOXYGEN) && !defined(SWIG)
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(messaging)
#endif  // !defined(DOXYGEN) && !defined(SWIG)

namespace firebase {

/// @brief Firebase Cloud Messaging API.
///
/// Firebase Cloud Messaging allows you to send data from your server to your
/// users' devices, and receive messages from devices on the same connection
/// if you're using a XMPP server.
///
/// The FCM service handles all aspects of queueing of messages and delivery
/// to client applications running on target devices.
namespace messaging {

/// @brief A class to configure the behavior of Firebase Cloud Messaging.
///
/// This class contains various configuration options that control some of
/// Firebase Cloud Messaging's behavior.
struct MessagingOptions {
  /// Default constructor.
  MessagingOptions() : suppress_notification_permission_prompt(false) {}

  /// If true, do not display the prompt to the user requesting permission to
  /// allow notifications to this app. If the prompt is suppressed in this way,
  /// the developer must manually prompt the user for permission at some point
  /// in the future using `RequestPermission()`.
  ///
  /// If this prompt has already been accepted once in the past the prompt will
  /// not be displayed again.
  ///
  /// This option currently only applies to iOS and tvOS.
  bool suppress_notification_permission_prompt;
};

/// @brief Data structure for parameters that are unique to the Android
/// implementation.
struct AndroidNotificationParams {
  /// The channel id that was provided when the message was sent.
  std::string channel_id;
};

/// Used for messages that display a notification.
///
/// On android, this requires that the app is using the Play Services client
/// library.
struct Notification {
  Notification() : android(nullptr) {}

#ifndef SWIG
  /// Copy constructor. Makes a deep copy of this Message.
  Notification(const Notification& other) : android(nullptr) { *this = other; }
#endif  // !SWIG

#ifndef SWIG
  /// Copy assignment operator. Makes a deep copy of this Message.
  Notification& operator=(const Notification& other) {
    this->title = other.title;
    this->body = other.body;
    this->icon = other.icon;
    this->sound = other.sound;
    this->tag = other.tag;
    this->color = other.color;
    this->click_action = other.click_action;
    this->body_loc_key = other.body_loc_key;
    this->body_loc_args = other.body_loc_args;
    this->title_loc_key = other.title_loc_key;
    this->title_loc_args = other.title_loc_args;
    delete this->android;
    if (other.android) {
      this->android = new AndroidNotificationParams(*other.android);
    } else {
      this->android = nullptr;
    }
    return *this;
  }
#endif  // !SWIG

  /// Destructor.
  ~Notification() { delete android; }

  /// Indicates notification title. This field is not visible on tvOS, iOS
  /// phones and tablets.
  std::string title;

  /// Indicates notification body text.
  std::string body;

  /// Indicates notification icon. Sets value to myicon for drawable resource
  /// myicon.
  std::string icon;

  /// Indicates a sound to play when the device receives the notification.
  /// Supports default, or the filename of a sound resource bundled in the
  /// app.
  ///
  /// Android sound files must reside in /res/raw/, while iOS and tvOS sound
  /// files can be in the main bundle of the client app or in the
  /// Library/Sounds folder of the app’s data container.
  std::string sound;

  /// Indicates the badge on the client app home icon. iOS and tvOS only.
  std::string badge;

  /// Indicates whether each notification results in a new entry in the
  /// notification drawer on Android. If not set, each request creates a new
  /// notification. If set, and a notification with the same tag is already
  /// being shown, the new notification replaces the existing one in the
  /// notification drawer.
  std::string tag;

  /// Indicates color of the icon, expressed in \#rrggbb format. Android only.
  std::string color;

  /// The action associated with a user click on the notification.
  ///
  /// On Android, if this is set, an activity with a matching intent filter is
  /// launched when user clicks the notification.
  ///
  /// If set on iOS or tvOS, corresponds to category in APNS payload.
  std::string click_action;

  /// Indicates the key to the body string for localization.
  ///
  /// On iOS and tvOS, this corresponds to "loc-key" in APNS payload.
  ///
  /// On Android, use the key in the app's string resources when populating this
  /// value.
  std::string body_loc_key;

  /// Indicates the string value to replace format specifiers in body string
  /// for localization.
  ///
  /// On iOS and tvOS, this corresponds to "loc-args" in APNS payload.
  ///
  /// On Android, these are the format arguments for the string resource. For
  /// more information, see [Formatting strings][1].
  ///
  /// [1]:
  /// https://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling
  std::vector<std::string> body_loc_args;

  /// Indicates the key to the title string for localization.
  ///
  /// On iOS and tvOS, this corresponds to "title-loc-key" in APNS payload.
  ///
  /// On Android, use the key in the app's string resources when populating this
  /// value.
  std::string title_loc_key;

  /// Indicates the string value to replace format specifiers in title string
  /// for localization.
  ///
  /// On iOS and tvOS, this corresponds to "title-loc-args" in APNS payload.
  ///
  /// On Android, these are the format arguments for the string resource. For
  /// more information, see [Formatting strings][1].
  ///
  /// [1]:
  /// https://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling
  std::vector<std::string> title_loc_args;

  /// Parameters that are unique to the Android implementation.
  AndroidNotificationParams* android;
};

/// @brief Data structure used to send messages to, and receive messages from,
/// cloud messaging.
struct Message {
  /// Initialize the message.
  Message()
      : time_to_live(0),
        notification(nullptr),
        notification_opened(false),
        sent_time(0) {}

  /// Destructor.
  ~Message() { delete notification; }

#ifndef SWIG
  /// Copy constructor. Makes a deep copy of this Message.
  Message(const Message& other) : notification(nullptr) { *this = other; }
#endif  // !SWIG

#ifndef SWIG
  /// Copy assignment operator. Makes a deep copy of this Message.
  Message& operator=(const Message& other) {
    this->from = other.from;
    this->to = other.to;
    this->collapse_key = other.collapse_key;
    this->data = other.data;
    this->raw_data = other.raw_data;
    this->message_id = other.message_id;
    this->message_type = other.message_type;
    this->priority = other.priority;
    this->original_priority = other.original_priority;
    this->sent_time = other.sent_time;
    this->time_to_live = other.time_to_live;
    this->error = other.error;
    this->error_description = other.error_description;
    delete this->notification;
    if (other.notification) {
      this->notification = new Notification(*other.notification);
    } else {
      this->notification = nullptr;
    }
    this->notification_opened = other.notification_opened;
    this->link = other.link;
    return *this;
  }
#endif  // !SWIG

  /// Authenticated ID of the sender. This is a project number in most cases.
  ///
  /// Any value starting with google.com, goog. or gcm. are reserved.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  std::string from;

  /// This parameter specifies the recipient of a message.
  ///
  /// For example it can be a registration token, a topic name, an Instance ID
  /// or project ID.
  ///
  /// PROJECT_ID@gcm.googleapis.com or Instance ID are accepted.
  std::string to;

  /// This parameter identifies a group of messages (e.g., with collapse_key:
  /// "Updates Available") that can be collapsed, so that only the last message
  /// gets sent when delivery can be resumed.  This is intended to avoid sending
  /// too many of the same messages when the device comes back online or becomes
  /// active.
  ///
  /// Note that there is no guarantee of the order in which messages get sent.
  ///
  /// Note: A maximum of 4 different collapse keys is allowed at any given time.
  /// This means a FCM connection server can simultaneously store 4 different
  /// send-to-sync messages per client app. If you exceed this number, there is
  /// no guarantee which 4 collapse keys the FCM connection server will keep.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  std::string collapse_key;

  /// The metadata, including all original key/value pairs. Includes some of the
  /// HTTP headers used when sending the message. `gcm`, `google` and `goog`
  /// prefixes are reserved for internal use.
  std::map<std::string, std::string> data;

  /// Binary payload.
  std::vector<unsigned char> raw_data;

  /// Message ID. This can be specified by sender. Internally a hash of the
  /// message ID and other elements will be used for storage. The ID must be
  /// unique for each topic subscription - using the same ID may result in
  /// overriding the original message or duplicate delivery.
  std::string message_id;

  /// Equivalent with a content-type.
  ///
  /// Defined values:
  ///   - "deleted_messages" - indicates the server had too many messages and
  ///     dropped some, and the client should sync with his own server.
  ///     Current limit is 100 messages stored.
  ///   - "send_event" - indicates an upstream message has been pushed to the
  ///     FCM server. It does not guarantee the upstream destination received
  ///     it.
  ///     Parameters: "message_id"
  ///   - "send_error" - indicates an upstream message expired, without being
  ///     sent to the FCM server.
  ///     Parameters: "message_id" and "error"
  ///
  /// If this field is missing, the message is a regular message.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  std::string message_type;

  /// Sets the priority of the message. Valid values are "normal" and "high." On
  /// iOS and tvOS, these correspond to APNs priority 5 and 10.
  ///
  /// By default, messages are sent with normal priority. Normal priority
  /// optimizes the client app's battery consumption, and should be used unless
  /// immediate delivery is required. For messages with normal priority, the app
  /// may receive the message with unspecified delay.
  ///
  /// When a message is sent with high priority, it is sent immediately, and the
  /// app can wake a sleeping device and open a network connection to your
  /// server.
  ///
  /// For more information, see [Setting the priority of a message][1].
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  ///
  /// [1]:
  /// https://firebase.google.com/docs/cloud-messaging/concept-options#setting-the-priority-of-a-message
  std::string priority;

  /// This parameter specifies how long (in seconds) the message should be kept
  /// in FCM storage if the device is offline. The maximum time to live
  /// supported is 4 weeks, and the default value is 4 weeks. For more
  /// information, see [Setting the lifespan of a message][1].
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  ///
  /// [1]: https://firebase.google.com/docs/cloud-messaging/concept-options#ttl
  int32_t time_to_live;

  /// Error code. Used in "nack" messages for CCS, and in responses from the
  /// server.
  /// See the CCS specification for the externally-supported list.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  std::string error;

  /// Human readable details about the error.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  std::string error_description;

  /// Optional notification to show. This only set if a notification was
  /// received with this message, otherwise it is null.
  ///
  /// The notification is only guaranteed to be valid during the call to
  /// Listener::OnMessage(). If you need to keep it around longer you will need
  /// to make a copy of either the Message or Notification. Copying the Message
  /// object implicitly makes a deep copy of the notification (allocated with
  /// new) which is owned by the Message.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  Notification* notification;

  /// A flag indicating whether this message was opened by tapping a
  /// notification in the OS system tray. If the message was received this way
  /// this flag is set to true.
  bool notification_opened;

  /// The link into the app from the message.
  ///
  /// This field is only used for downstream messages received through
  /// Listener::OnMessage().
  std::string link;

  /// @cond FIREBASE_APP_INTERNAL
  /// Original priority of the message.
  std::string original_priority;

  /// UTC timestamp in milliseconds when the message was sent.
  /// See https://en.wikipedia.org/wiki/Unix_time for details of UTC.
  int64_t sent_time;
  /// @endcond
};

/// @brief Base class used to receive messages from Firebase Cloud Messaging.
///
/// You need to override base class methods to handle any events required by the
/// application. Methods are invoked asynchronously and may be invoked on other
/// threads.
class Listener {
 public:
  virtual ~Listener();

  /// Called on the client when a message arrives.
  ///
  /// @param[in] message The data describing this message.
  virtual void OnMessage(const Message& message) = 0;

  /// Called on the client when a registration token arrives. This function
  /// will eventually be called in response to a call to
  /// firebase::messaging::Initialize(...).
  ///
  /// @param[in] token The registration token.
  virtual void OnTokenReceived(const char* token) = 0;
};

/// @brief Initialize Firebase Cloud Messaging.
///
/// After Initialize is called, the implementation may call functions on the
/// Listener provided at any time.
///
/// @param[in] app The Firebase App object for this application.
/// @param[in] listener A Listener object that listens for events from the
///            Firebase Cloud Messaging servers.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is
/// not available on the current device.
InitResult Initialize(const App& app, Listener* listener);

/// @brief Initialize Firebase Cloud Messaging.
///
/// After Initialize is called, the implementation may call functions on the
/// Listener provided at any time.
///
/// @param[in] app The Firebase App object for this application.
/// @param[in] listener A Listener object that listens for events from the
///            Firebase Cloud Messaging servers.
/// @param[in] options A set of options that configure the
///            initialzation behavior of Firebase Cloud Messaging.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is
/// not available on the current device.
InitResult Initialize(const App& app, Listener* listener,
                      const MessagingOptions& options);

/// @brief Terminate Firebase Cloud Messaging.
///
/// Frees resources associated with Firebase Cloud Messaging.
///
/// @note On Android, the services will not be shut down by this method.
void Terminate();

/// Determines if automatic token registration during initalization is enabled.
///
/// @return true if auto token registration is enabled and false if disabled.
bool IsTokenRegistrationOnInitEnabled();

/// Enable or disable token registration during initialization of Firebase Cloud
/// Messaging.
///
/// This token is what identifies the user to Firebase, so disabling this avoids
/// creating any new identity and automatically sending it to Firebase, unless
/// consent has been granted.
///
/// If this setting is enabled, it triggers the token registration refresh
/// immediately. This setting is persisted across app restarts and overrides the
/// setting "firebase_messaging_auto_init_enabled" specified in your Android
/// manifest (on Android) or Info.plist (on iOS and tvOS).
///
/// <p>By default, token registration during initialization is enabled.
///
/// The registration happens before you can programmatically disable it, so
/// if you need to change the default, (for example, because you want to prompt
/// the user before FCM generates/refreshes a registration token on app
/// startup), add to your application’s manifest:
///
///
/// @if NOT_DOXYGEN
///   <meta-data android:name="firebase_messaging_auto_init_enabled"
///   android:value="false" />
/// @else
/// @code
///   &lt;meta-data android:name="firebase_messaging_auto_init_enabled"
///   android:value="false" /&gt;
/// @endcode
/// @endif
///
/// or on iOS or tvOS to your Info.plist:
///
/// @if NOT_DOXYGEN
///   <key>FirebaseMessagingAutoInitEnabled</key>
///   <false/>
/// @else
/// @code
///   &lt;key&gt;FirebaseMessagingAutoInitEnabled&lt;/key&gt;
///   &lt;false/&gt;
/// @endcode
/// @endif
///
/// @param enable sets if a registration token should be requested on
/// initialization.
void SetTokenRegistrationOnInitEnabled(bool enable);

#ifndef SWIG
/// @brief Set the listener for events from the Firebase Cloud Messaging
/// servers.
///
/// A listener must be set for the application to receive messages from
/// the Firebase Cloud Messaging servers.  The implementation may call functions
/// on the Listener provided at any time.
///
/// @param[in] listener A Listener object that listens for events from the
///            Firebase Cloud Messaging servers.
///
/// @return Pointer to the previously set listener.
Listener* SetListener(Listener* listener);
#endif  // !SWIG

/// Error code returned by Firebase Cloud Messaging C++ functions.
enum Error {
  /// The operation was a success, no error occurred.
  kErrorNone = 0,
  /// Permission to receive notifications was not granted.
  kErrorFailedToRegisterForRemoteNotifications,
  /// Topic name is invalid for subscription/unsubscription.
  kErrorInvalidTopicName,
  /// Could not subscribe/unsubscribe because there is no registration token.
  kErrorNoRegistrationToken,
  /// Unknown error.
  kErrorUnknown,
};

/// @brief Displays a prompt to the user requesting permission to display
///        notifications.
///
/// The permission prompt only appears on iOS and tvOS. If the user has
/// already agreed to allow notifications, no prompt is displayed and the
/// returned future is completed immediately.
///
/// @return A future that completes when the notification prompt has been
///         dismissed.
Future<void> RequestPermission();

/// @brief Gets the result of the most recent call to RequestPermission();
///
/// @return Result of the most recent call to RequestPermission().
Future<void> RequestPermissionLastResult();

/// @brief Subscribe to receive all messages to the specified topic.
///
/// Subscribes an app instance to a topic, enabling it to receive messages
/// sent to that topic.
///
/// Call this function from the main thread. FCM is not thread safe.
///
/// @param[in] topic The name of the topic to subscribe. Must match the
///            following regular expression: `[a-zA-Z0-9-_.~%]{1,900}`.
Future<void> Subscribe(const char* topic);

/// @brief Gets the result of the most recent call to Unsubscribe();
///
/// @return Result of the most recent call to Unsubscribe().
Future<void> SubscribeLastResult();

/// @brief Unsubscribe from a topic.
///
/// Unsubscribes an app instance from a topic, stopping it from receiving
/// any further messages sent to that topic.
///
/// Call this function from the main thread. FCM is not thread safe.
///
/// @param[in] topic The name of the topic to unsubscribe from. Must match the
///            following regular expression: `[a-zA-Z0-9-_.~%]{1,900}`.
Future<void> Unsubscribe(const char* topic);

/// @brief Gets the result of the most recent call to Unsubscribe();
///
/// @return Result of the most recent call to Unsubscribe().
Future<void> UnsubscribeLastResult();

/// Determines whether Firebase Cloud Messaging exports message delivery metrics
/// to BigQuery.
///
/// This function is currently only implemented on Android, and returns false
/// with no other behavior on other platforms.
///
/// @return true if Firebase Cloud Messaging exports message delivery metrics to
/// BigQuery.
bool DeliveryMetricsExportToBigQueryEnabled();

/// Enables or disables Firebase Cloud Messaging message delivery metrics export
/// to BigQuery.
///
/// By default, message delivery metrics are not exported to BigQuery. Use this
/// method to enable or disable the export at runtime. In addition, you can
/// enable the export by adding to your manifest. Note that the run-time method
/// call will override the manifest value.
///
/// <meta-data android:name= "delivery_metrics_exported_to_big_query_enabled"
///            android:value="true"/>
///
/// This function is currently only implemented on Android, and has no behavior
/// on other platforms.
///
/// @param[in] enable Whether Firebase Cloud Messaging should export message
///            delivery metrics to BigQuery.
void SetDeliveryMetricsExportToBigQuery(bool enable);

/// @brief This creates a Firebase Installations ID, if one does not exist, and
/// sends information about the application and the device where it's running to
/// the Firebase backend.
///
/// @return A future with the token.
Future<std::string> GetToken();

/// @brief Gets the result of the most recent call to GetToken();
///
/// @return Result of the most recent call to GetToken().
Future<std::string> GetTokenLastResult();

/// @brief Deletes the default token for this Firebase project.
///
/// Note that this does not delete the Firebase Installations ID that may have
/// been created when generating the token. See Installations.Delete() for
/// deleting that.
///
/// @return A future that completes when the token is deleted.
Future<void> DeleteToken();

/// @brief Gets the result of the most recent call to DeleteToken();
///
/// @return Result of the most recent call to DeleteToken().
Future<void> DeleteTokenLastResult();

class PollableListenerImpl;

/// @brief A listener that can be polled to consume pending `Message`s.
///
/// This class is intended to be used with applications that have a main loop
/// that frequently updates, such as in the case of a game that has a main
/// loop that updates 30 to 60 times a second. Rather than respond to incoming
/// messages and tokens via the `OnMessage` virtual function, this class will
/// queue up the message internally in a thread-safe manner so that it can be
/// consumed with `PollMessage`. For example:
///
///     ::firebase::messaging::PollableListener listener;
///     ::firebase::messaging::Initialize(app, &listener);
///
///     while (true) {
///       std::string token;
///       if (listener.PollRegistrationToken(&token)) {
///         LogMessage("Received a registration token");
///       }
///
///       ::firebase::messaging::Message message;
///       while (listener.PollMessage(&message)) {
///         LogMessage("Received a new message");
///       }
///
///       // Remainder of application logic...
///     }
class PollableListener : public Listener {
 public:
  /// @brief The default constructor.
  PollableListener();

  /// @brief The required virtual destructor.
  virtual ~PollableListener();

  /// @brief An implementation of `OnMessage` which adds the incoming messages
  /// to a queue, which can be consumed by calling `PollMessage`.
  virtual void OnMessage(const Message& message);

  /// @brief An implementation of `OnTokenReceived` which stores the incoming
  /// token so that it can be consumed by calling `PollRegistrationToken`.
  virtual void OnTokenReceived(const char* token);

  /// @brief Returns the first message queued up, if any.
  ///
  /// If one or more messages has been received, the first message in the
  /// queue will be popped and used to populate the `message` argument and the
  /// function will return `true`. If there are no pending messages, `false` is
  /// returned. This function should be called in a loop until all messages have
  /// been consumed, like so:
  ///
  ///     ::firebase::messaging::Message message;
  ///     while (listener.PollMessage(&message)) {
  ///       LogMessage("Received a new message");
  ///     }
  ///
  /// @param[out] message The `Message` struct to be populated. If there were no
  /// pending messages, `message` is not modified.
  ///
  /// @return Returns `true` if there was a pending message, `false` otherwise.
  bool PollMessage(Message* message);

  /// @brief Returns the registration key, if a new one has been received.
  ///
  /// When a new registration token is received, it is cached internally and can
  /// be retrieved by calling `PollRegistrationToken`. The cached registration
  /// token will be used to populate the `token` argument, then the cache will
  /// be cleared and the function will return `true`. If there is no cached
  /// registration token this function retuns `false`.
  ///
  ///     std::string token;
  ///     if (listener.PollRegistrationToken(&token)) {
  ///       LogMessage("Received a registration token");
  ///     }
  ///
  /// @param[out] token A string to be populated with the new token if one has
  /// been received. If there were no new token, the string is left unmodified.
  ///
  /// @return Returns `true` if there was a new token, `false` otherwise.
  bool PollRegistrationToken(std::string* token) {
    bool got_token;
    std::string token_received = PollRegistrationToken(&got_token);
    if (got_token) {
      *token = token_received;
    }
    return got_token;
  }

 private:
  std::string PollRegistrationToken(bool* got_token);

  // The implementation of the `PollableListener`.
  PollableListenerImpl* impl_;
};

}  // namespace messaging
}  // namespace firebase

#endif  // FIREBASE_MESSAGING_SRC_INCLUDE_FIREBASE_MESSAGING_H_
